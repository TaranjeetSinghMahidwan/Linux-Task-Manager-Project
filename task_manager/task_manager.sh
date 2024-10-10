#!/bin/bash

# Task Manager Script

TASK_FILE="tasks.txt"

function initialize {
    if [ ! -f "$TASK_FILE" ]; then
        touch "$TASK_FILE"
    fi
}

function add_task {
    read -p "Enter task description: " task
    read -p "Enter task priority (1-5): " priority
    read -p "Enter task deadline (YYYY-MM-DD): " deadline

    if [[ ! $priority =~ ^[1-5]$ ]]; then
        echo "Invalid priority. Please enter a number between 1 and 5."
        return
    fi

    echo "$task|$priority|$deadline" >> "$TASK_FILE"
    echo "Task added."
}

function list_tasks {
    echo "Current tasks:"
    if [ -s "$TASK_FILE" ]; then
        echo "ID   Description            Priority   Deadline"
        echo "------------------------------------------------"
        nl -w2 -s'. ' "$TASK_FILE" | while IFS='|' read -r line; do
            IFS='|' read -r desc prio due <<< "$line"
            printf "%-5s %-22s %-10s %-10s\n" "$REPLY" "$desc" "$prio" "$due"
        done
    else
        echo "No tasks available."
    fi
}

function update_task {
    list_tasks
    read -p "Enter task number to update: " task_number

    if [[ $task_number =~ ^[0-9]+$ ]]; then
        if sed -n "${task_number}p" "$TASK_FILE" >/dev/null; then
            read -p "Enter new task description (leave blank to keep current): " new_desc
            read -p "Enter new priority (1-5, leave blank to keep current): " new_priority
            read -p "Enter new deadline (YYYY-MM-DD, leave blank to keep current): " new_deadline

            # Read current task details
            current_task=$(sed -n "${task_number}p" "$TASK_FILE")
            IFS='|' read -r current_desc current_prio current_due <<< "$current_task"

            # Use current values if new ones are not provided
            desc="${new_desc:-$current_desc}"
            priority="${new_priority:-$current_prio}"
            deadline="${new_deadline:-$current_due}"

            if [[ ! $priority =~ ^[1-5]$ ]] && [ -n "$new_priority" ]; then
                echo "Invalid priority. Please enter a number between 1 and 5."
                return
            fi

            # Update the task in the file
            sed -i "${task_number}s/.*/$desc|$priority|$deadline/" "$TASK_FILE"
            echo "Task updated."
        else
            echo "Invalid task number."
        fi
    else
        echo "Invalid task number."
    fi
}

function delete_task {
    list_tasks
    read -p "Enter task number to delete: " task_number
    if [[ $task_number =~ ^[0-9]+$ ]]; then
        sed -i "${task_number}d" "$TASK_FILE"
        echo "Task deleted."
    else
        echo "Invalid task number."
    fi
}

function show_menu {
    echo "Task Manager"
    echo "1. Add Task"
    echo "2. List Tasks"
    echo "3. Update Task"
    echo "4. Delete Task"
    echo "5. Exit"
}

function main {
    initialize
    while true; do
        show_menu
        read -p "Select an option: " option
        case $option in
            1) add_task ;;
            2) list_tasks ;;
            3) update_task ;;
            4) delete_task ;;
            5) echo "Exiting."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

main
