## 🍒 Cherry picking guide for kernel developers.
<hr>

### 01. First, create a new repository in github, Open the terminal in your kernel source's folder and type these commands to upload your source to github :
- Source must be clean.

```
git init
git add -A
git add -f .
git commit -m "Uploaded from source"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```
### 02. Then we have to fetch a repository, which we'd like to cherry-pick commits from. Use this command (make sure you are running this command inside of your source's folder) :
- Replace the github link with the target repo's link.

```
git remote add ANY_NAME https://github.com/ravindu644/android_kernel_beyond2.git
git fetch ANY_NAME
```

### 03. Now, We can start cherry-picking.

#### i). If you want to pick a single commit, use this command :

```
git cherry-pick commit_hash
```

example :

```
git cherry-pick a9459dfd1f736705e987b2864409c06a2d7bcf1a
```

#### ii). If you want to pick multiple commits, you can use this command :

```
git cherry-pick FIRST_COMMIT_HASH
git cherry-pick FIRST_COMMIT_HASH..LAST_COMMIT_HASH
```

**Notes :** If there are conflicts while cherry picking process, you have to find the conflicted line by yourself and fix the conflict. so, you have to use your brain. You can find conflicted lines from easily by searching `<<<`.

- After resolving conflicts, you can continue the cherry-picking process using this command : `git cherry-pick ---continue`.
- If you want to skip the certain commit with the conflict, you can use this command : `git cherry-pick --skip`.
- If you want to abort the whole cherry-picking process, use this command : `git cherry-pick --abort`.


#### iii). After you finished cherry-picking process, you can push the changes to your Github repo using this command :

```
git push origin BRANCH_NAME
```

<hr>

## Git for Newbies.

#### 01. To add all the files in the kernel source :
```
git add -A
git add -f .
git commit -m "Uploaded files"
```
#### 02. To add a single file and commit its changes :
```
git add path/to/filename.extension
git commit -m "Edited FILENAME"
```
#### 03. To create a new branch :
```
git checkout -b BRANCH_NAME
```
#### 04. To push the changes to github :
```
git push origin BRANCH_NAME
```

- Notes : you must add files and make a commit before uploading files.

<hr>

## Patch files guide :

#### 01. To apply a patch file :
```
patch -p1 <  FILENAME_PATCH.patch
```

#### 02. To create a patch file using a certain github commit :
```
git checkout COMMIT_HASH
git diff HEAD^ > filename.patch
```   
