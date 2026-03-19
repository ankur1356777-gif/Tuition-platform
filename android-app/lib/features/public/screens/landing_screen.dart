import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/public_service.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landingAsync = ref.watch(landingDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tuition Platform'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Login'),
          ),
        ],
      ),
      body: landingAsync.when(
        data: (data) {
          final banners = data['banners'] as List;
          final teachers = data['teachers'] as List;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banners.isNotEmpty) _buildBannerSlider(banners),
                const SizedBox(height: 20),
                _buildSectionHeader('Find Your Perfect Tutor', context),
                _buildActionButtons(context),
                const SizedBox(height: 20),
                _buildSectionHeader('Top Rated Teachers', context),
                _buildTeacherList(teachers),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(landingDataProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/public/request'),
        label: const Text('Book a Demo Free'),
        icon: const Icon(Icons.touch_app),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBannerSlider(List banners) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
                image: banner['image_url'] != null
                   ? DecorationImage(
                        image: NetworkImage(banner['image_url']),
                        fit: BoxFit.cover,
                      )
                   : null,
              ),
              child: banner['image_url'] == null 
                ? const Center(child: Icon(Icons.image, size: 50, color: Colors.white))
                : null,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/public/request'),
              icon: const Icon(Icons.school),
              label: const Text('I need a Tutor'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/register?role=teacher'),
              icon: const Icon(Icons.person_add),
              label: const Text('Become a Tutor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherList(List teachers) {
    if (teachers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No teachers available right now.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teachers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: teacher['photo'] != null ? NetworkImage(teacher['photo']) : null,
              child: teacher['photo'] == null ? const Icon(Icons.person) : null,
            ),
            title: Text(teacher['name'] ?? 'Tutor'),
            subtitle: Text('${teacher['subjects']?.join(", ") ?? "All Subjects"} • ${teacher['experience'] ?? 0} Yrs Exp'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
