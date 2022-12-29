import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/common/error_text.dart';
import 'package:sorun_takip_sistemi/core/common/loader.dart';
import 'package:sorun_takip_sistemi/features/project/controller/project_controller.dart';

class SearchProjectDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchProjectDelegate({required this.ref});
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      onPressed: () {
        Routemaster.of(context).pop();
      },
      icon: const Icon(Icons.arrow_back_sharp),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return ref.watch(getProjectsByQueryProvider(query)).when(
          data: (projects) => ListView.builder(
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              final project = projects[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(project.projectPic),
                ),
                title: Text(project.title),
                onTap: () => navigateToProject(context, project.id),
              );
            },
          ),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }

  void navigateToProject(BuildContext context, String projectId) {
    Routemaster.of(context).push('/projects/$projectId');
  }
}
