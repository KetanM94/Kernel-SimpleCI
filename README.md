These scripts are used to build your kernel on CI (e.g. GitHub).

# Setting up
## Prequisite
- setup your kernel and device inside postmarketOS pmaports (don't have to boot, just should be in-place)
- pmbootstrap should lead to pmbootstrap.py inside your pmbootstrap instalation
## Main setup

### Linux repository
- create your cloned kernel tree on CI (script is designed to take kernel tree from different repository than where is build script hosted)
- create branch with your kernel and version (e.g. qcom-apq8064-v5.10), you can create multiple (`v5.10`, `v5.4`, `next` as you need)
### This repository hosted on CI
Note: can be also same repository as with Linux kernel.
- modify .github/workflows/build.yml to accept your branch and kernel version(s)
- trigger build by doing git push (e.g. something like `git add .github/workflows/build.yml && git commit --amend -m "latest" && git push --force`)
- after job(s) will finish, it exports tarball as a tagged release
- setup variables inside `upload_kernel.sh` to reflect your device and kernel
- continue on your work computer by running `./upload_kernel.sh _your_branch_` (e.g. `./upload_kernel.sh qcom-apq8064-v5.10`)
- voilà, you should have booted new kernel on your device

# Structure
## on CI
- `.github/workflows/build.yml` - defines what version will be build and tested
- `build.sh` - builds a kernel defined by build.yml
- `dtb_check.sh` - does bindings and DTB checks, so everything is correct

## on computer
- `upload_kernel.sh` - just directly grabs a build and send it to the device

# Limitations of CI
- you can run maximally 20 tasks at same moment
- approximate build takes about 8 - 16 minutes (not depending how much parallel builds you run)
