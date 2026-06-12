# GitHub Workflow Instructions

## Branch Structure

Each team member should work on their own development branch:

```text
main
├── amir-dev
├── hanan-dev
└── amjad-dev
```

Do **not** work directly on the `main` branch.

---

## Initial Setup

1. Clone the repository using GitHub Desktop.
2. Open the repository in GitHub Desktop.
3. Create your personal branch:

### Amir

```text
amir-dev
```

### Hanan

```text
hanan-dev
```

### Amjad

```text
amjad-dev
```

To create a branch in GitHub Desktop:

* Click **Current Branch**
* Select **New Branch**
* Enter your branch name (`name-dev`)
* Click **Create Branch**

---

## Daily Work Process

Before starting work:

1. Open GitHub Desktop.
2. Select your personal branch.
3. Fetch and pull the latest changes if available.

Make all modifications only on your branch.

---

## Saving Changes

After completing a task:

1. Review the changed files.
2. Enter a commit message describing your changes.

Examples:

```text
Implemented Instruction Memory
Added ALU operations
Connected datapath components
Fixed control signal generation
```

3. Click **Commit to your branch**.

---

## Uploading Changes to GitHub

After committing:

1. Click **Push Origin**.

This uploads your work to GitHub while keeping it isolated from the `main` branch.

---

## Merging into Main

When your assigned module is completed and tested:

1. Ensure all changes have been committed.
2. Click **Push Origin**.
3. Notify the integration team member (Amjad) or create a Pull Request.

The branch can then be merged into `main` after verification.

---

## Important Rules

### DO

* Work only on your personal branch.
* Commit frequently.
* Use clear commit messages.
* Push your work regularly to GitHub.

### DO NOT

* Commit directly to `main`.
* Push unfinished code to `main`.
* Delete another team member's branch.
* Modify another team member's files unless coordinated.

---

## Recommended Workflow

```text
1. Checkout personal branch
2. Implement feature
3. Commit changes
4. Push Origin
5. Test functionality
6. Merge into main when completed
```

Following this workflow will keep the project organized and minimize merge conflicts during integration.
