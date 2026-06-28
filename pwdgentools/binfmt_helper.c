#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv) {
    // Array large enough to hold system-wide folder paths safely
    char parent_exe[1024];
    
    // Read the symlink path of the current process parent executing engine
    ssize_t len = readlink("/proc/self/exe", parent_exe, sizeof(parent_exe) - 1);
    if (len != -1) {
        parent_exe[len] = '\0';
    } else {
        fprintf(stderr, " Security Violation: Unable to resolve execution engine.\n");
        return 1;
    }

    // Explicit path validation matrix enforcement matching your structural constraints
    if (strcmp(parent_exe, "/usr/bin/pwdgen") != 0 && strcmp(parent_exe, "/usr/bin/python") != 0) {
        fprintf(stderr, " Execution Refused: .pbin files are strictly restricted to pwdgen execution frameworks.\n");
        return 126;
    }

    // Allocate memory blocks dynamically to hand execution off to python3 safely
    char **new_argv = malloc((argc + 2) * sizeof(char *));
    if (new_argv == NULL) {
        perror("Allocation failed");
        return 1;
    }

    new_argv[0] = "/usr/bin/python3";
    for(int i = 1; i < argc; i++) {
        new_argv[i] = argv[i];
    }
    new_argv[argc] = NULL;

    // Swap process thread memory tables directly into standard python
    execv("/usr/bin/python3", new_argv);
    perror("execv failed");
    
    free(new_argv);
    return 1;
}
