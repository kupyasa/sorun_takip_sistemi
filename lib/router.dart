import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/features/auth/view/edit_user_screen.dart';
import 'package:sorun_takip_sistemi/features/auth/view/forgot_password.dart';
import 'package:sorun_takip_sistemi/features/auth/view/login.dart';
import 'package:sorun_takip_sistemi/features/auth/view/register.dart';
import 'package:sorun_takip_sistemi/features/auth/view/user_screen.dart';
import 'package:sorun_takip_sistemi/features/issue/view/create_issue_screen.dart';
import 'package:sorun_takip_sistemi/features/issue/view/edit_issue_screen.dart';
import 'package:sorun_takip_sistemi/features/issue/view/issue_screen.dart';
import 'package:sorun_takip_sistemi/features/issue/view/issues_screen.dart';
import 'package:sorun_takip_sistemi/features/notification/view/notifications_screen.dart';
import 'package:sorun_takip_sistemi/features/project/view/add_members_to_project_screen.dart';
import 'package:sorun_takip_sistemi/features/project/view/create_project_screen.dart';
import 'package:sorun_takip_sistemi/features/project/view/home_screen.dart';
import 'package:sorun_takip_sistemi/features/project/view/project_members_screen.dart';
import 'package:sorun_takip_sistemi/features/project/view/project_screen.dart';

import 'features/project/view/edit_project_screen.dart';

final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: LoginScreen(),
        ),
    '/register': (_) => const MaterialPage(
          child: RegisterScreen(),
        ),
    '/forgot-password': (_) => const MaterialPage(
          child: ForgotPasswordScreen(),
        )
  },
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: HomeScreen(),
        ),
    '/create-project': (_) => const MaterialPage(
          child: CreateProjectScreen(),
        ),
    '/projects/:projectId': (route) => MaterialPage(
          child: ProjectScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/projects/:projectId/edit': (route) => MaterialPage(
          child: EditProjectScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/users/:uid': (route) => MaterialPage(
          child: UserScreen(
            uid: route.pathParameters['uid']!,
          ),
        ),
    '/users/:uid/edit': (route) => MaterialPage(
          child: UserEditScreen(
            uid: route.pathParameters['uid']!,
          ),
        ),
    '/projects/:projectId/members': (route) => MaterialPage(
          child: ProjectMembersScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/projects/:projectId/addmembers': (route) => MaterialPage(
          child: AddMembersToProjectScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/notifications': (route) => const MaterialPage(
          child: NotificationScreen(),
        ),
    '/projects/:projectId/issues': (route) => MaterialPage(
          child: ProjectIssuesScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/projects/:projectId/issues/create': (route) => MaterialPage(
          child: CreateIssueScreen(
            projectId: route.pathParameters['projectId']!,
          ),
        ),
    '/projects/:projectId/issues/:issueId': (route) => MaterialPage(
          child: IssueScreen(
            projectId: route.pathParameters['projectId']!,
            issueId: route.pathParameters['issueId']!,
          ),
        ),
    '/projects/:projectId/issues/:issueId/edit': (route) => MaterialPage(
          child: EditIssueScreen(
            projectId: route.pathParameters['projectId']!,
            issueId: route.pathParameters['issueId']!,
          ),
        )
  },
);
