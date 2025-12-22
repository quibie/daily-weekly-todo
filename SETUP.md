# Setup Guide for Daily Weekly Todo

## Quick Setup for GitHub Repository

### 1. Create GitHub Repository
1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `daily-weekly-todo` 
3. Make it public (for free GitHub Actions)
4. Don't initialize with README (we already have files)

### 2. Initialize Git and Push
```bash
cd daily-weekly-todo
git init
git add .
git commit -m "Initial commit: WoW Daily Weekly Todo addon"
git branch -M main
git remote add origin https://github.com/YOURUSERNAME/daily-weekly-todo.git
git push -u origin main
```

### 3. Create Your First Release
```bash
# Tag your first release
git tag v1.0.0
git push origin v1.0.0
```

This will automatically trigger GitHub Actions to:
- Create a release page
- Generate `DailyWeeklyTodo-v1.0.0.zip`
- Generate `DailyWeeklyTodo-latest.zip`
- Calculate checksums
- Update the .toc version automatically

### 4. Update README Links
After creating your repository, update these placeholders in README.md:
- Replace `yourusername` with your actual GitHub username
- Replace `yourusername/daily-weekly-todo` with your repository path

## GitHub Actions Benefits

### Free Tier Includes:
- **Public repositories**: Unlimited GitHub Actions minutes
- **Private repositories**: 2,000 minutes/month free
- Automatic releases on git tags
- Professional-looking release pages
- Downloadable zip files for addon managers

### What the Workflow Does:
1. **Triggers**: Automatically runs when you push version tags (`v1.0.0`, `v1.2.3`, etc.)
2. **Version Update**: Updates the .toc file with the correct version number
3. **Package Creation**: Creates properly structured zip files
4. **Release Creation**: Creates GitHub release with changelog
5. **Asset Upload**: Uploads both versioned and latest zip files
6. **Checksums**: Generates SHA256 checksums for verification

## Addon Manager Compatibility

The generated zip files are compatible with:
- **Curse/Overwolf**: Standard addon structure
- **WowUp**: Recognizes GitHub releases automatically
- **Ajour**: Can track releases via repository URL

## Release Workflow

### Automatic Releases (Recommended)
```bash
# Make your changes
git add .
git commit -m "Fix weekly reset bug"

# Create and push a version tag
git tag v1.0.1
git push origin v1.0.1

# GitHub Actions will automatically:
# 1. Create release v1.0.1
# 2. Generate zip files
# 3. Update .toc version
```

### Manual Releases
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Create Release" workflow
4. Click "Run workflow"
5. Enter version number (e.g., v1.0.1)
6. Click "Run workflow"

## Troubleshooting

### GitHub Actions Not Running
- Ensure repository is public or you have Actions enabled
- Check that the workflow file is in `.github/workflows/release.yml`
- Verify the tag follows semver format (`v1.0.0`, not `1.0.0`)

### Zip File Issues
- Check that all .lua and .toc files are included
- Verify folder structure is `DailyWeeklyTodo/` inside the zip
- Ensure file permissions are correct

### Version Not Updating
- Make sure the .toc file has the line `## Version: 1.0.0`
- Check that the sed command in the workflow can find the version line
- Verify tag format matches the expected pattern

## Next Steps

1. Push your code to GitHub
2. Create your first release tag
3. Share the repository URL with addon users
4. Users can install via addon managers or direct download
5. Update version tags for new releases - GitHub Actions handles the rest!

with tag now ?