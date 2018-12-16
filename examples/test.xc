#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef datatype SedSingleCommand SedSingleCommand;
datatype SedSingleCommand {
        Delete();
        Append(char *);
};

typedef datatype SedAddress SedAddress;
datatype SedAddress {
        LineAddr(int);
        LineRangeAddr(int, int);
        AnyAddr();
};

typedef struct SedCommand {
        SedAddress *addr;
        SedSingleCommand *cmd;
} SedCommand;

typedef struct SedProgram {
        SedCommand *cmds;
        int num_cmds;
} SedProgram;

static void run_sed_program(SedProgram *prog, FILE *in, FILE *out);
static bool addr_matches(SedAddress *addr, int line_number,
        char *pattern_space);
static void execute_sed_command(SedSingleCommand *cmd, char **pattern_space,
        ssize_t *pattern_space_len, size_t *buf_size, bool *skip_to_next_cycle);
static void execute_delete(char **pattern_space, ssize_t *pattern_space_len);
static void execute_append(char *s, char **pattern_space,
        ssize_t *pattern_space_len, size_t *buf_size);

int main(void)
{
        /* you can think of this as being the abstract syntax of the following
         * sed program: "1 d; 2~3 a :append this ... ; a : append this ..."
         * the idea is for your extension generate code like in this main() */
        SedCommand cmds[] = {
                {LineAddr(1), Delete()},
                {LineRangeAddr(2, 3), Append(": append this to certain lines")},
                {AnyAddr(), Append(": append this to all lines")},
        };

        SedProgram sed_program = {
                cmds, 3
        };

        run_sed_program(&sed_program, stdin, stdout);

        return 0;
}

/* you do not need to generate any of the following code */

void run_sed_program(SedProgram *prog, FILE *in, FILE *out)
{
        char *pattern_space = NULL;
        ssize_t pattern_space_len;
        size_t buf_size = 0;
        int line_number = 1;

        /* read one line at a time, storing the line in the pattern space */
        while ((pattern_space_len = getline(&pattern_space, &buf_size, in)) > 0) {
                /* remove trailing "\n" */
                pattern_space[pattern_space_len-1] = '\0';

                bool skip_to_next_cycle = false;

                /* for each command in the program, run it if the address
                 * matches this line */
                for (int i=0; i < prog->num_cmds && !skip_to_next_cycle; ++i) {
                        if (addr_matches(prog->cmds[i].addr, line_number,
                                                pattern_space)) {
                                execute_sed_command(prog->cmds[i].cmd,
                                        &pattern_space, &pattern_space_len,
                                        &buf_size, &skip_to_next_cycle);
                        }
                }

                /* print the pattern space */
                if (!skip_to_next_cycle) {
                        fprintf(out, "%s\n", pattern_space);
                }

                ++line_number;
        }
}

bool addr_matches(SedAddress *addr, int line_number, char *pattern_space)
{
        bool ret = false;

        match (addr) {
                LineAddr(n) -> { ret = n == line_number; }
                LineRangeAddr(n1, n2) -> {
                        ret = n1 <= line_number && line_number <= n2;
                }
                AnyAddr() -> { ret = true; }
        }

        return ret;
}

void execute_sed_command(SedSingleCommand *cmd, char **pattern_space,
        ssize_t *pattern_space_len, size_t *buf_size, bool *skip_to_next_cycle)
{
        match (cmd) {
                Delete() -> {
                        execute_delete(pattern_space, pattern_space_len);
                        *skip_to_next_cycle = true;
                }
                Append(s) -> {
                        execute_append(s, pattern_space, pattern_space_len,
                                        buf_size);
                }
        }
}

void execute_delete(char **pattern_space, ssize_t *pattern_space_len)
{
        (*pattern_space)[0] = '\0';
        *pattern_space_len = 0;
}

void execute_append(char *s, char **pattern_space, ssize_t *pattern_space_len,
        size_t *buf_size)
{
        /* TODO: make sure *buf_size is big enough */
        (*pattern_space)[*pattern_space_len - 1] = '\n';
        strcpy(*pattern_space + *pattern_space_len, s);
        *pattern_space_len += strlen(s);
}
