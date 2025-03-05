1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

In my shell, after creating child processes for each command, I use waitpid() in a loop to pause the shell until all child processes are done. This happens in execute_pipeline(), where the parent process waits for each command before moving on.

If I forget waitpid(), the shell wouldn’t wait for commands to finish. This means:

The shell prompt (dsh3>) would appear too early, even before commands complete.
Some processes could become "zombie" processes, meaning they are done but not properly removed from the system.
If multiple commands run at the same time, their output might mix together, making it hard to read.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

Pipes pass data between commands. When we use dup2(), we redirect input and output to use the pipes instead of the normal keyboard (stdin) or screen (stdout). But after doing this, we must close unused pipe ends.

If we don’t close pipes, these problems can happen:

Too many pipes stay open, and the system might run out of file handles.
If a process is waiting for input but the write end of the pipe is still open, it waits forever.
If a pipe is still open, it can send extra data or make a command think it needs to wait for more input.


3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

The cd command changes the current working directory. It must be a built-in command because it affects the shell itself.

If cd was an external command:

It would run in a child process created by fork().
The child process would change its directory using chdir(), but then exit.
The parent shell wouldn’t change directories, so it would stay in the same place.

For example: dsh3> cd /tmp
If cd was external, after running, the shell would still be in the old directory instead of /tmp.
This is why, in my shell, cd is handled inside exec_built_in_cmd(), where it uses chdir() directly in the parent shell process.




4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

Right now, my shell only allows a fixed number of commands in a pipeline (CMD_MAX = 8). To remove this limit, I can dynamically allocate memory instead of using a fixed array.
Tradeoffs:
Good:
More flexible → The user can enter as many piped commands as they want.
Uses only as much memory as needed, saving space.
Bad:
Memory management is harder → If I forget to free() memory, my shell could leak memory.
Slower → Allocating and resizing memory takes more time than using a fixed array.