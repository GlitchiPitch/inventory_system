# /start Command

**Description:** Initializes work on the project by analyzing the current state and determining the next development stages

## Action Sequence

### 1. Project Documentation Check
- Search for `.docs` folder in project root
- If folder doesn't exist - create and add file with project state description
- If folder exists - read and analyze existing documentation

### 2. Project State Analysis
- Check IMPLEMENTATION_TODO.md for relevance
- Analysis of completed and unfinished tasks
- Assessment of current development progress

### 3. Determination of Next Stages
- Identification of priority tasks for implementation
- Determination of dependencies between components
- Planning of development sequence

### 4. Information Output
- Display of current project status in chat
- List of next development stages
- Recommendations on implementation priorities

## Output Format
```
📋 Next Development Stages:

### Stage 1: {Stage Name} (v{X}.{Y}.{Z}) - PRIORITY
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Stage 2: {Stage Name}
- [ ] Task 1
- [ ] Task 2

**Next Step:** {specific recommendations}
```