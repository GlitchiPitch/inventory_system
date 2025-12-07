# /commit Command

**Description:** Performs a complete commit cycle with documentation and game version updates

## Action Sequence

### 1. Documentation Update
- Review and update CHANGELOG.md
- Update IMPLEMENTATION_TODO.md
- Check relevance of other documents in docs/

### 2. Game Version Update
- Increment version in GameVersion.model.json
- Update version number in code (if applicable)
- Check version compatibility

### 3. Analysis and Planning
- Check task status in IMPLEMENTATION_TODO.md
- Determine next development steps
- Assess project progress

### 4. Creating Commit
- Form commit message with new version
- Add all changes to index
- Execute commit with version description
- Commit must be made in English language

## Commit Format
```
v{X}.{Y}.{Z} - {brief description of changes}

- Change 1
- Change 2
- Next steps: {plan for next version}
```
