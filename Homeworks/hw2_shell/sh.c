#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

// Simplifed xv6 shell.

#define MAXARGS 10

// All commands have at least a type. Have looked at the type, the code
// typically casts the *cmd to some specific cmd type.
struct cmd {
    int type;  //  ' ' (exec), | (pipe), '<' or '>' for redirection
};

struct execcmd {
    int type;             // ' '
    char *argv[MAXARGS];  // arguments to the command to be exec-ed
};

struct redircmd {
    int type;         // < or >
    struct cmd *cmd;  // the command to be run (e.g., an execcmd)
    char *file;       // the input/output file
    int flags;        // flags for open() indicating read or write
    int fd;           // the file descriptor number to use for the file
                      // YY: Do not know why we need the field
};

struct pipecmd {
    int type;           // |
    struct cmd *left;   // left side of pipe
    struct cmd *right;  // right side of pipe
};

int fork1(void);  // Fork but exits on failure.
struct cmd *parsecmd(char *);

// Execute cmd.  Never returns.
void runcmd(struct cmd *cmd) {
    int p[2], r;
    struct execcmd *ecmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;

    if (cmd == 0)
        _exit(0);

    switch (cmd->type) {
        int pid_left, pid_right;

        default:
            fprintf(stderr, "unknown runcmd\n");
            _exit(-1);

        case ' ':
            ecmd = (struct execcmd *)cmd;
            if (ecmd->argv[0] == 0)
                _exit(0);

            if (fork1() == 0) {
                char binStr[10];
                char usrBinStr[10];
                strcpy(binStr, "/bin/");
                strcpy(usrBinStr, "/usr/bin/");

                // Try to execute directly
                if (execv(ecmd->argv[0], ecmd->argv) < 0) {
                    // YY: note you cannot use string literal directly in strcat.
                    // Though no error/warninig would be given.
                    if (execv(strcat(binStr, ecmd->argv[0]), ecmd->argv) < 0) {
                        if (execv(strcat(usrBinStr, ecmd->argv[0]), ecmd->argv) < 0) {
                            fprintf(stderr, "Command not found: %s\n", ecmd->argv[0]);
                            _exit(-1);
                        }
                    }
                }
            } else {
                wait(NULL);
            }
            break;

        case '<':
        case '>':
            /**
             * Seems that the parsing code follows this parsing rule:
             * "execmd (< or >) file", which matches with the examples given:
             * echo "6.828 is cool" > x.txt, cat < x.txt.
             */
            rcmd = (struct redircmd *)cmd;

            if (fork1() == 0) {
                close(1);                       // close std output
                open(rcmd->file, rcmd->flags);  // Child process see fd = 1
                runcmd(rcmd->cmd);
            } else {
                wait(NULL);
            }
            break;

        // case '|':
        //     /**
        //      * By default, pipe is blocking. Thus, no explicit synchronization is
        //      * needed for the pipe. The pipe's read() blocks until there are
        //      * data available.
        //      * You should understand that, though the file descriptor is changed
        //      * by dup(), the underlying file is not changed. The behavior is
        //      * still the behavior of the pipe.
        //      */
        //     pcmd = (struct pipecmd *)cmd;

        //     int p[2];
        //     pipe(p);

        //     // Run left
        //     if (fork1() == 0) {
        //         close(1);
        //         dup(p[1]);  // dup write end to fd 1

        //         close(p[0]);  // close pipe
        //         close(p[1]);
        //         runcmd(pcmd->left);
        //     }

        //     // Run right
        //     if (fork1() == 0) {
        //         close(0);
        //         dup(p[0]);  // dup read end to fd 0

        //         close(p[0]);  // close pipe
        //         close(p[1]);
        //         runcmd(pcmd->right);
        //     }

        //     // These two closes are very important !!!
        //     // As we call fork() 3 times, 3 processes share the pipe. close()
        //     // would decrement the reference count of the read/write end of the
        //     // pipe accordingly.
        //     // However, if the pipe is not closed in the parent process, then
        //     // read(), in the right command, would keeps being blocked, though
        //     // the left command can exit normally. You can verify this by adding
        //     // a wait() after the code for left command.
        //     close(p[0]);
        //     close(p[1]);

        //     wait(NULL);
        //     wait(NULL);
        //     break;

            // case '|':  // With single fork
            //         pcmd = (struct pipecmd *)cmd;

            //         int p[2];
            //         pipe(p);

            //         // Run right
            //         if (fork1() == 0) {
            //             close(0);
            //             dup(p[0]);  // dup read end to fd 0

            //             close(p[0]);  // close pipe
            //             close(p[1]);
            //             runcmd(pcmd->right);
            //         }

            //         // Run left
            //         close(1);
            //         dup(p[1]);  // dup write end to fd 1

            //         close(p[0]);  // close pipe
            //         close(p[1]);
            //         runcmd(pcmd->left); // Note that it _exit().

            case '|':  // With single fork
                pcmd = (struct pipecmd *)cmd;

                int p[2];
                pipe(p);

                // Run left
                if (fork1() == 0) {
                    close(1);
                    dup(p[1]);  // dup write end to fd 1

                    close(p[0]);  // close pipe
                    close(p[1]);
                    runcmd(pcmd->left);
                }

                wait(NULL);

                // Run right
                close(0);
                dup(p[0]);  // dup read end to fd 0

                close(p[0]);  // close pipe
                close(p[1]);

                runcmd(pcmd->right);
    }
    _exit(0);
}

int getcmd(char *buf, int nbuf) {
    if (isatty(fileno(stdin)))
        fprintf(stdout, "6.828$ ");
    memset(buf, 0, nbuf);
    if (fgets(buf, nbuf, stdin) == 0)
        return -1;  // EOF
    return 0;
}

int main(void) {
    static char buf[100];
    int fd, r;

    // Read and run input commands.
    while (getcmd(buf, sizeof(buf)) >= 0) {
        if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ') {
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            buf[strlen(buf) - 1] = 0;  // chop \n
            if (chdir(buf + 3) < 0)
                fprintf(stderr, "cannot cd %s\n", buf + 3);
            continue;
        }
        if (fork1() == 0)  // YY: In the child process
            runcmd(parsecmd(buf));
        wait(&r);
    }
    exit(0);
}

int fork1(void) {
    int pid;

    pid = fork();
    if (pid == -1)
        perror("fork");
    return pid;
}

// YY: Constructors
struct cmd *
execcmd(void) {
    struct execcmd *cmd;

    cmd = malloc(sizeof(*cmd));
    memset(cmd, 0, sizeof(*cmd));
    cmd->type = ' ';
    return (struct cmd *)cmd;
}

struct cmd *
redircmd(struct cmd *subcmd, char *file, int type) {
    struct redircmd *cmd;

    cmd = malloc(sizeof(*cmd));
    memset(cmd, 0, sizeof(*cmd));

    cmd->type = type;
    cmd->cmd = subcmd;
    cmd->file = file;
    cmd->flags = (type == '<') ? O_RDONLY : O_WRONLY | O_CREAT | O_TRUNC;
    cmd->fd = (type == '<') ? 0 : 1;
    return (struct cmd *)cmd;
}

struct cmd *
pipecmd(struct cmd *left, struct cmd *right) {
    struct pipecmd *cmd;

    cmd = malloc(sizeof(*cmd));
    memset(cmd, 0, sizeof(*cmd));
    cmd->type = '|';
    cmd->left = left;
    cmd->right = right;
    return (struct cmd *)cmd;
}

// Parsing
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>";

int gettoken(char **ps, char *es, char **q, char **eq) {
    char *s;
    int ret;

    s = *ps;
    while (s < es && strchr(whitespace, *s))
        s++;
    if (q)
        *q = s;
    ret = *s;
    switch (*s) {
        case 0:
            break;
        case '|':
        case '<':
            s++;
            break;
        case '>':
            s++;
            break;
        default:
            ret = 'a';
            while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
                s++;
            break;
    }
    if (eq)
        *eq = s;

    while (s < es && strchr(whitespace, *s))
        s++;
    *ps = s;
    return ret;
}

int peek(char **ps, char *es, char *toks) {
    char *s;

    // YY: Forward pointer s until reaching the first non-whitespace character
    // The pointer passed in would point to the 1st non-whitespace char
    s = *ps;
    while (s < es && strchr(whitespace, *s))
        s++;
    *ps = s;

    // YY: Return value
    // If the whole character is whitespace (then *s is '\0'),
    // or the first non-whitespace character is not in toks,
    // then the return value would be 0.
    // Otherwise, return value would be non-zero.
    return *s && strchr(toks, *s);
}

struct cmd *parseline(char **, char *);
struct cmd *parsepipe(char **, char *);
struct cmd *parseexec(char **, char *);

// make a copy of the characters in the input buffer, starting from s through es.
// null-terminate the copy to make it a string.
char *mkcopy(char *s, char *es) {
    int n = es - s;
    char *c = malloc(n + 1);
    assert(c);
    strncpy(c, s, n);
    c[n] = 0;
    return c;
}

struct cmd *
parsecmd(char *s) {
    char *es;
    struct cmd *cmd;

    es = s + strlen(s);
    cmd = parseline(&s, es);
    peek(&s, es, "");
    if (s != es) {
        fprintf(stderr, "leftovers: %s\n", s);
        exit(-1);
    }
    return cmd;
}

struct cmd *
parseline(char **ps, char *es) {
    struct cmd *cmd;
    cmd = parsepipe(ps, es);
    return cmd;
}

struct cmd *
parsepipe(char **ps, char *es) {
    struct cmd *cmd;

    cmd = parseexec(ps, es);
    if (peek(ps, es, "|")) {
        gettoken(ps, es, 0, 0);
        cmd = pipecmd(cmd, parsepipe(ps, es));
    }
    return cmd;
}

struct cmd *
parseredirs(struct cmd *cmd, char **ps, char *es) {
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>")) {
        tok = gettoken(ps, es, 0, 0);
        if (gettoken(ps, es, &q, &eq) != 'a') {
            fprintf(stderr, "missing file for redirection\n");
            exit(-1);
        }
        switch (tok) {
            case '<':
                cmd = redircmd(cmd, mkcopy(q, eq), '<');
                break;
            case '>':
                cmd = redircmd(cmd, mkcopy(q, eq), '>');
                break;
        }
    }
    return cmd;
}

struct cmd *
parseexec(char **ps, char *es) {
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;

    ret = execcmd();
    cmd = (struct execcmd *)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
    while (!peek(ps, es, "|")) {
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a') {
            fprintf(stderr, "syntax error\n");
            exit(-1);
        }
        cmd->argv[argc] = mkcopy(q, eq);
        argc++;
        if (argc >= MAXARGS) {
            fprintf(stderr, "too many args\n");
            exit(-1);
        }
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    return ret;
}