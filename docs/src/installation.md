# Installing the ImageNet Dataset
The ImageNet 2012 Classification Dataset (ILSVRC 2012-2017) can be downloaded at
[image-net.org](https://image-net.org/) after signing up and accepting the terms of access.
It is therefore required that you download this dataset manually.

## Existing Installation
The dataset structure is assumed to look as follows:
```
ImageNet
├── train
├── val
│   ├── n01440764
│   │   ├── ILSVRC2012_val_00000293.JPEG
│   │   ├── ILSVRC2012_val_00002138.JPEG
│   │   └── ...
│   ├── n01443537
│   └── ...
├── test
└── devkit
    ├── data
    │   ├── meta.mat
    │   └── ...
    └── ...
```

!!! tip "Using individual splits"
    ImageNetDataset.jl can be used to load a single split 
    and doesn't require all subdirectories `train`, `test` and `val` to be available.

ImageNetDataset.jl expects the `ImageNet` directory to live in `~/.julia/datadeps/`.
If this structure is not given, we offer two solutions:

### Option 1: Specifying custom directories
When creating an [`ImageNet`](@ref) dataset, a custom root directory can be specified via the keyword argument `dir`:

```julia
dir = joinpath(homedir(), "Path", "To", "ImageNet")
dataset = ImageNet(; dir=dir)
```

If the existing subdirectory names differ from `train`, `val`, `test` and `devkit` as well, 
they can be changed via the keyword arguments `train_dir`, `val_dir`, `test_dir` and `devkit_dir`.

### Option 2: Using symbolic links
Instead of manually specifying directories,
you can also create a symbolic link from your existing installation to `~/.julia/datadeps/ImageNet`.

On Unix-like operating systems, this can be done using `ln`:
```bash
ln -s my/path/to/ImageNet ~/.julia/datadeps/ImageNet
```

In case the subdirectory structure is different as well, multiple symbolic links 
can be set to the following directories:
* `~/.julia/datadeps/ImageNet/train`
* `~/.julia/datadeps/ImageNet/val`
* `~/.julia/datadeps/ImageNet/test`
* `~/.julia/datadeps/ImageNet/devkit`

## New Installation
Download the following files from the [ILSVRC2012 download page](https://image-net.org/challenges/LSVRC/2012/2012-downloads.php):

| Name                          | File name                           | Size  | Note                               |
|:------------------------------|:------------------------------------|:------|:-----------------------------------|
| Development kit (Task 1 & 2)  | `ILSVRC2012_devkit_t12.tar.gz`      | 2.5MB | Always required, contains metadata | 
| Training images (Task 1 & 2)  | `ILSVRC2012_img_train.tar`          | 138GB | Only required for `:train` split   |
| Validation images (all tasks) | `ILSVRC2012_img_val.tar`            | 6.3GB | Only required for `:val` split     |
| Test images (all tasks)       | `ILSVRC2012_img_test_v10102019.tar` | 13GB  | Only required for `:test` split    | 

You can use ImageNetDataset.jl without downloading all splits.

After downloading the data, move and extract the training and validation images to
labeled subfolders by running the following shell script:

```bash
# Extract the training data:
mkdir -p ImageNet/train && tar -xvf ILSVRC2012_img_train.tar -C ImageNet/train

# Unpack all 1000 compressed tar-files, one for each category:
cd ImageNet/train
find . -name "*.tar" | while read NAME ; do mkdir -p "\${NAME%.tar}"; tar -xvf "\${NAME}" -C "\${NAME%.tar}"; rm -f "\${NAME}"; done

# Extract the validation data:
cd ../..
mkdir -p ImageNet/val && tar -xvf ILSVRC2012_img_val.tar -C ImageNet/val

# Extract metadata from the devkit:
cd ../..
mkdir -p ImageNet/devkit && tar -xvf ILSVRC2012_devkit_t12.tar.gz -C ImageNet/devkit --strip-components=1
```

And run the following script 
[adapted from soumith](https://github.com/soumith/imagenetloader.torch/blob/master/valprep.sh) 
to create all class directories and move images into corresponding directories:

```bash
cd ImageNet/val
wget -qO- https://raw.githubusercontent.com/adrhill/ImageNetDataset.jl/master/docs/src/valprep.sh | bash
```
    