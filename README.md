# todo-cli

WIP

## TODO :
### Add a task:
`todo add <description> [options]`

Descriptions are unique.

#### options
- `-t <deadline>` sets the deadline.

### List tasks:
 `todo [options]`
 
 or `todo list`

By default it lists the unckecked todos.

#### options
- `-d` Lists the "done" tasks.
- `-a` Lists all tasks.
- `-o` Lists overdue or expired tasks.
- `-s <order>` Sorts the output, by default it's by `task_index`.

Sort orders:
- Description `d`
- Deadline `t`
- Accomplished date `a`

### Remove a task:
`todo remove <task index>`

### Check a task (mark as done):
`todo check [task_index=0]`

If unspecified, it will check the first task.

### Uncheck a task (mark as done):
`todo uncheck [task_index=0]`

If unspecified, it will uncheck the first task.

### Edit a task:
`todo edit <task_index> [options]`

#### options
- `-d <description>` changes the description.
- `-t <deadline>` changes the deadline.

### Move a task's priority:
`todo move <task_index> <before_index>`

Will move the task with `task_index` above the `before_index`.
