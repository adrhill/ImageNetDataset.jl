var documenterSearchIndex = {"docs":
[{"location":"installation/#Installing-the-ImageNet-Dataset","page":"Installation","title":"Installing the ImageNet Dataset","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"The ImageNet 2012 Classification Dataset (ILSVRC 2012-2017) can be downloaded at image-net.org after signing up and accepting the terms of access. It is therefore required that you download this dataset manually.","category":"page"},{"location":"installation/#Existing-Installation","page":"Installation","title":"Existing Installation","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"The dataset structure is assumed to look as follows:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"ImageNet\n├── train\n├── val\n│   ├── n01440764\n│   │   ├── ILSVRC2012_val_00000293.JPEG\n│   │   ├── ILSVRC2012_val_00002138.JPEG\n│   │   └── ...\n│   ├── n01443537\n│   └── ...\n├── test\n└── devkit\n    ├── data\n    │   ├── meta.mat\n    │   └── ...\n    └── ...","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"tip: Using individual splits\nImageNetDataset.jl can be used to load a single split  and doesn't require all subdirectories train, test and val to be available.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"ImageNetDataset.jl expects the ImageNet directory to live in ~/.julia/datadeps/. If this structure is not given, we offer two solutions:","category":"page"},{"location":"installation/#Option-1:-Specifying-custom-directories","page":"Installation","title":"Option 1: Specifying custom directories","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"When creating an ImageNet dataset, a custom root directory can be specified via the keyword argument dir:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"dir = joinpath(homedir(), \"Path\", \"To\", \"ImageNet\")\ndataset = ImageNet(; dir=dir)","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"If the existing subdirectory names differ from train, val, test and devkit as well,  they can be changed via the keyword arguments train_dir, val_dir, test_dir and devkit_dir.","category":"page"},{"location":"installation/#Option-2:-Using-symbolic-links","page":"Installation","title":"Option 2: Using symbolic links","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"Instead of manually specifying directories, you can also create a symbolic link from your existing installation to ~/.julia/datadeps/ImageNet.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"On Unix-like operating systems, this can be done using ln:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"ln -s my/path/to/ImageNet ~/.julia/datadeps/ImageNet","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"In case the subdirectory structure is different as well, multiple symbolic links  can be set to the following directories:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"~/.julia/datadeps/ImageNet/train\n~/.julia/datadeps/ImageNet/val\n~/.julia/datadeps/ImageNet/test\n~/.julia/datadeps/ImageNet/devkit","category":"page"},{"location":"installation/#New-Installation","page":"Installation","title":"New Installation","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"Download the following files from the ILSVRC2012 download page:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"Name File name Size Note\nDevelopment kit (Task 1 & 2) ILSVRC2012_devkit_t12.tar.gz 2.5MB Always required, contains metadata\nTraining images (Task 1 & 2) ILSVRC2012_img_train.tar 138GB Only required for :train split\nValidation images (all tasks) ILSVRC2012_img_val.tar 6.3GB Only required for :val split\nTest images (all tasks) ILSVRC2012_img_test_v10102019.tar 13GB Only required for :test split","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"You can use ImageNetDataset.jl without downloading all splits.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"After downloading the data, move and extract the training and validation images to labeled subfolders by running the following shell script:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"# Extract the training data:\nmkdir -p ImageNet/train && tar -xvf ILSVRC2012_img_train.tar -C ImageNet/train\n\n# Unpack all 1000 compressed tar-files, one for each category:\ncd ImageNet/train\nfind . -name \"*.tar\" | while read NAME ; do mkdir -p \"\\${NAME%.tar}\"; tar -xvf \"\\${NAME}\" -C \"\\${NAME%.tar}\"; rm -f \"\\${NAME}\"; done\n\n# Extract the validation data:\ncd ../..\nmkdir -p ImageNet/val && tar -xvf ILSVRC2012_img_val.tar -C ImageNet/val\n\n# Extract metadata from the devkit:\ncd ../..\nmkdir -p ImageNet/devkit && tar -xvf ILSVRC2012_devkit_t12.tar.gz -C ImageNet/devkit --strip-components=1","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"And run the following script  adapted from soumith  to create all class directories and move images into corresponding directories:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"cd ImageNet/val\nwget -qO- https://raw.githubusercontent.com/adrhill/ImageNetDataset.jl/master/docs/src/valprep.sh | bash","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = ImageNetDataset","category":"page"},{"location":"#ImageNetDataset","page":"Home","title":"ImageNetDataset","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ImageNetDataset.","category":"page"},{"location":"#API-Reference","page":"Home","title":"API Reference","text":"","category":"section"},{"location":"#Dataset","page":"Home","title":"Dataset","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"ImageNet\nconvert2image","category":"page"},{"location":"#ImageNetDataset.ImageNet","page":"Home","title":"ImageNetDataset.ImageNet","text":"ImageNet(; split=:train, dir=nothing, kwargs...)\nImageNet([split])\n\nThe ImageNet 2012 Classification Dataset (ILSVRC 2012-2017).\n\nThis is the most highly-used subset of ImageNet. It spans 1000 object classes and contains 1,281,167 training images, 50,000 validation images and 100,000 test images. By defaults, each image is in 224 × 224 × 3 format in RGB color space. This can be changed by modifying the preprocessor transform.\n\nArguments\n\nYou can pass a specific dir where to load or download the dataset, otherwise uses the default one.\ntrain_dir, val_dir, test_dir, devkit_dir: optional subdirectory names of dir.   Default to \"train\", \"val\", \"test\" and \"devkit\".\nsplit: selects the data partition. Can take the values :train:, :val and :test.   Defaults to :train.\ntransform: preprocessor applied to convert an image file to an array.   Assumes a file path as input and an array in WHC format as output.   Defaults to CenterCropNormalize, which applies a center-cropping view   and normalization using coefficients from PyTorch's vision models.\n\nFields\n\nsplit: Symbol indicating the selected data partition\ntransform: Preprocessing pipeline. Can be configured to select output dimensions and type.\npaths: paths to ImageNet images\ntargets: An array storing the targets for supervised learning.\nmetadata: A dictionary containing additional information on the dataset.\n\nAlso refer to AbstractTransform, CenterCropNormalize.\n\nMethods\n\ndataset[i]: Return observation(s) i as a named tuple of features and targets.\ndataset[:]: Return all observations as a named tuple of features and targets.\nlength(dataset): Number of observations.\nconvert2image converts features to RGB images.\n\nExamples\n\njulia> using ImageNetDataset\n\njulia> dataset = ImageNet(:val);\n\njulia> dataset[1:5].targets\n5-element Vector{Int64}:\n 1\n 1\n 1\n 1\n 1\n\njulia> X, y = dataset[1:5];\n\njulia> size(X)\n(224, 224, 3, 5)\n\njulia> X, y = dataset[2000];\n\njulia> convert2image(dataset, X)\n\njulia> dataset.metadata\nDict{String, Any} with 4 entries:\n  \"class_WNIDs\"       => [\"n01440764\", \"n01443537\", \"n01484850\", \"n01491361\", \"n01494475\", …\n  \"class_description\" => [\"freshwater dace-like game fish of Europe and western Asia noted …\n  \"class_names\"       => Vector{SubString{String}}[[\"tench\", \"Tinca tinca\"], [\"goldfish\", \"…\n  \"wnid_to_label\"     => Dict(\"n07693725\"=>932, \"n03775546\"=>660, \"n01689811\"=>45, \"n021008…\n\njulia> dataset.metadata[\"class_names\"][y]\n  3-element Vector{SubString{String}}:\n   \"common iguana\"\n   \"iguana\"\n   \"Iguana iguana\"\n\nReferences\n\n[1]: Russakovsky et al., ImageNet Large Scale Visual Recognition Challenge\n\n\n\n\n\n","category":"type"},{"location":"#ImageNetDataset.convert2image","page":"Home","title":"ImageNetDataset.convert2image","text":"convert2image(dataset::ImageNet, i)\nconvert2image(dataset::ImageNet, x)\n\nConvert the observation(s) i from dataset d to image(s). It can also convert a numerical array x.\n\nExamples\n\njulia> using ImageNetDataset, ImageInTerminal\n\njulia> d = ImageNet()\n\njulia> convert2image(d, 1:2)\n# You should see 2 images in the terminal\n\njulia> x = d[1].features;\n\njulia> convert2image(MNIST, x) # or convert2image(d, x)\n\n\n\n\n\n","category":"function"},{"location":"#Preprocessing","page":"Home","title":"Preprocessing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"AbstractTransform\nCenterCropNormalize\nRandomCropNormalize","category":"page"},{"location":"#ImageNetDataset.AbstractTransform","page":"Home","title":"ImageNetDataset.AbstractTransform","text":"AbstractTransform\n\nAbstract type of ImageNet Preprocessing pipelines. Expected interface:\n\ntransform(method, image_path): load image and convert it to a WHC array\ninverse_transform(method, array): convert WHC[N] array to image[s]\n\n\n\n\n\n","category":"type"},{"location":"#ImageNetDataset.CenterCropNormalize","page":"Home","title":"ImageNetDataset.CenterCropNormalize","text":"CenterCropNormalize([; output_size, open_size, mean, std])\n\nPreprocessing pipeline center-crops an input image to output_size and normalizes it according to mean and std. Returns an array in WHC format (width, height, channels).\n\nApplied using transform and inverse_transform.\n\nKeyword arguments:\n\noutput_size: Output size (width, height) of the center-crop. Defaults to (224, 224).\nopen_size: Preferred size (width, height) to open the image in using JpegTurbo. Defaults to (256, 256)\nmean: Mean of the normalization over color channels. Defaults to (0.485f0, 0.456f0, 0.406f0).\nstd: Standard deviation of the normalization over color channels Defaults to (0.229f0, 0.224f0, 0.225f0).\n\n\n\n\n\n","category":"type"},{"location":"#ImageNetDataset.RandomCropNormalize","page":"Home","title":"ImageNetDataset.RandomCropNormalize","text":"RandomCropNormalize([; output_size, open_size, mean, std])\n\nPreprocessing pipeline crops an input image to output_size at a random position and normalizes it according to mean and std. Returns an array in WHC format (width, height, channels).\n\nApplied using transform and inverse_transform.\n\nKeyword arguments:\n\noutput_size: Output size (width, height) of the center-crop. Defaults to (224, 224).\nopen_size: Preferred size (width, height) to open the image in using JpegTurbo. Defaults to (256, 256)\nmean: Mean of the normalization over color channels. Defaults to (0.485f0, 0.456f0, 0.406f0).\nstd: Standard deviation of the normalization over color channels Defaults to (0.229f0, 0.224f0, 0.225f0).\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"Preprocessing transforms can also be applied manually:","category":"page"},{"location":"","page":"Home","title":"Home","text":"transform\ninverse_transform","category":"page"},{"location":"#ImageNetDataset.transform","page":"Home","title":"ImageNetDataset.transform","text":"transform(tfm, path)\n\nLoad image from path and convert it to a WHC array using preprocessing transformation tfm.\n\n\n\n\n\n","category":"function"},{"location":"#ImageNetDataset.inverse_transform","page":"Home","title":"ImageNetDataset.inverse_transform","text":"inverse_transform(tfm, path)\n\nConvert WHC array to an image by applying the inverse of the preprocessing transformation tfm.\n\n\n\n\n\n","category":"function"},{"location":"#Metadata","page":"Home","title":"Metadata","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"class\ndescription\nwnid","category":"page"},{"location":"#ImageNetDataset.class","page":"Home","title":"ImageNetDataset.class","text":"class(dataset, i)\n\nObtain class name for given target index i.\n\n\n\n\n\n","category":"function"},{"location":"#ImageNetDataset.description","page":"Home","title":"ImageNetDataset.description","text":"description(dataset, i)\n\nObtain class class description for given target index i.\n\n\n\n\n\n","category":"function"},{"location":"#ImageNetDataset.wnid","page":"Home","title":"ImageNetDataset.wnid","text":"wnid(dataset, i)\n\nObtain WordNet ID for given target index i.\n\n\n\n\n\n","category":"function"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}
