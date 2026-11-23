/*-
 * Copyright(c) 2024 Baptiste Daroussin <bapt@FreeBSD.org>
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

#include <pkg.h>

#include "pkgcli.h"

void
usage_repositories(void)
{
        fprintf(stderr,
	    "Usage: pkg repositories [-edl] [repository]\n"
	    "       pkg repositories <repository> <enable|disable|reset>\n\n");
}


typedef enum {
	REPO_SHOW_ALL = 0,
	REPO_SHOW_ENABLED = 1U << 0,
	REPO_SHOW_DISABLED = 1U << 1,
} repo_show_t;

/*
 * Ensure $PKG_DBDIR/repos_state/<subdir> exists and return its fd.
 */
static int
repos_state_subdir(const char *subdir)
{
	int dbfd, statefd, subfd;

	dbfd = pkg_get_dbdirfd();
	if (dbfd == -1) {
		warnx("Cannot open package database directory");
		return (-1);
	}

	statefd = openat(dbfd, "repos_state", O_DIRECTORY | O_CLOEXEC);
	if (statefd == -1) {
		if (mkdirat(dbfd, "repos_state", 0755) == -1) {
			warn("Cannot create repos_state directory");
			return (-1);
		}
		statefd = openat(dbfd, "repos_state", O_DIRECTORY | O_CLOEXEC);
		if (statefd == -1)
			return (-1);
	}

	subfd = openat(statefd, subdir, O_DIRECTORY | O_CLOEXEC);
	if (subfd == -1) {
		if (mkdirat(statefd, subdir, 0755) == -1) {
			warn("Cannot create repos_state/%s directory", subdir);
			close(statefd);
			return (-1);
		}
		subfd = openat(statefd, subdir, O_DIRECTORY | O_CLOEXEC);
	}
	close(statefd);
	return (subfd);
}

static int
repo_set_state(const char *reponame, const char *action)
{
	struct pkg_repo *repo;
	int fd;

	repo = pkg_repo_find(reponame);
	if (repo == NULL) {
		warnx("Unknown repository: %s", reponame);
		return (EXIT_FAILURE);
	}

	if (STREQ(action, "enable")) {
		/* Remove any disable override */
		fd = repos_state_subdir("disable");
		if (fd != -1) {
			unlinkat(fd, reponame, 0);
			close(fd);
		}
		/* Create enable override */
		fd = repos_state_subdir("enable");
		if (fd == -1)
			return (EXIT_FAILURE);
		int f = openat(fd, reponame, O_WRONLY | O_CREAT | O_TRUNC,
		    0644);
		close(fd);
		if (f == -1) {
			warn("Cannot create override for %s", reponame);
			return (EXIT_FAILURE);
		}
		close(f);
		printf("Repository '%s' has been enabled (override set)\n",
		    reponame);
	} else if (STREQ(action, "disable")) {
		/* Remove any enable override */
		fd = repos_state_subdir("enable");
		if (fd != -1) {
			unlinkat(fd, reponame, 0);
			close(fd);
		}
		/* Create disable override */
		fd = repos_state_subdir("disable");
		if (fd == -1)
			return (EXIT_FAILURE);
		int f = openat(fd, reponame, O_WRONLY | O_CREAT | O_TRUNC,
		    0644);
		close(fd);
		if (f == -1) {
			warn("Cannot create override for %s", reponame);
			return (EXIT_FAILURE);
		}
		close(f);
		printf("Repository '%s' has been disabled (override set)\n",
		    reponame);
	} else if (STREQ(action, "reset")) {
		fd = repos_state_subdir("enable");
		if (fd != -1) {
			unlinkat(fd, reponame, 0);
			close(fd);
		}
		fd = repos_state_subdir("disable");
		if (fd != -1) {
			unlinkat(fd, reponame, 0);
			close(fd);
		}
		printf("Repository '%s' override removed, "
		    "using configuration value\n", reponame);
	} else {
		warnx("Unknown action: %s (expected enable, disable, or reset)",
		    action);
		return (EXIT_FAILURE);
	}

	return (EXIT_SUCCESS);
}

int
exec_repositories(int argc, char **argv)
{
	const char *r = NULL;
	struct pkg_repo *repo = NULL;
	bool list_only = false;
	repo_show_t rs = REPO_SHOW_ALL;
	int ch;

	struct option longopts[] = {
		{ "list",	no_argument,	NULL,	'l' },
		{ "enabled",	no_argument,	NULL,	'e' },
		{ "disabled",	no_argument,	NULL,	'd' },
		{ NULL,		0,		NULL,	0   },
	};

	while ((ch = getopt_long(argc, argv, "+led", longopts, NULL)) != -1) {
                switch (ch) {
		case 'l':
			list_only = true;
			break;
		case 'e':
			rs |= REPO_SHOW_ENABLED;
			break;
		case 'd':
			rs |= REPO_SHOW_DISABLED;
			break;
		default:
			usage_repositories();
			return (EXIT_FAILURE);
		}
	}

	argc -= optind;
	argv += optind;

	/* pkg repositories <name> <enable|disable|reset> */
	if (argc == 2)
		return (repo_set_state(argv[0], argv[1]));

	if (rs == REPO_SHOW_ALL)
		rs |= REPO_SHOW_DISABLED|REPO_SHOW_ENABLED;

	if (argc == 1)
		r = argv[0];

	while (pkg_repos(&repo) == EPKG_OK) {
		if (r && !STREQ(r, pkg_repo_name(repo)))
			continue;
		if (pkg_repo_enabled(repo)) {
			if ((rs & REPO_SHOW_ENABLED) == 0)
				continue;
		} else {
			if ((rs & REPO_SHOW_DISABLED) == 0)
				continue;
		}
		if (list_only) {
			printf("%s\n", pkg_repo_name(repo));
			continue;
		}
		print_repository(repo, false);
	}


	return (EXIT_SUCCESS);
}
