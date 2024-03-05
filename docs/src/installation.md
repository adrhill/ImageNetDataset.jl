# Installing the ImageNet Dataset
The ImageNet 2012 Classification Dataset (ILSVRC 2012-2017) can be downloaded at
[image-net.org](https://image-net.org/) after signing up and accepting the terms of access.
It is therefore required that you download this dataset manually.

## Existing installation
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

DataDeps.jl expects this `ImageNet` directory to live in `~/.julia/datadeps/`.
If you already have an existing copy of the ImageNet dataset,
we recommend to create symbolic links, e.g. using `ln` on Unix-like operating systems:
```bash
ln -s my/path/to/ImageNet ~/.julia/datadeps/ImageNet
```

Im case your existing file structure is completely different, we recommend setting
individual symbolic links to the directories
* `~/.julia/datadeps/ImageNet/train`
* `~/.julia/datadeps/ImageNet/val`
* `~/.julia/datadeps/ImageNet/test`
* `~/.julia/datadeps/ImageNet/devkit`

## New installation
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

