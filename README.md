# ImageNetDataset.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://adrhill.github.io/ImageNetDataset.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://adrhill.github.io/ImageNetDataset.jl/dev/)
[![Build Status](https://github.com/adrhill/ImageNetDataset.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/adrhill/ImageNetDataset.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Data loader for the ImageNet 2012 Classification Dataset (ILSVRC 2012-2017) in Julia.

## Installation 

The ImageNet dataset can be downloaded at [image-net.org](https://image-net.org/) 
after signing up and accepting the terms of access.
It is therefore required that you download this dataset manually.

[Installation instructions can be found in the documentation.](https://adrhill.github.io/ImageNetDataset.jl/dev/installation/)

Afterwards, add this package via
```julia-repl
julia> ]add https://github.com/adrhill/ImageNetDataset.jl
```

## Examples
By default, the ImageNet dataset will be loaded with the `CenterCropNormalize` transformation.

This uses [JpegTurbo.jl](https://github.com/JuliaIO/JpegTurbo.jl) to open the image
and applies a center-cropping view to `(224, 224)` resolution to it.
Afterwards, the image is normalized over color channels using normalization constants 
which are compatible with most pretrained models from [Metalhead.jl](https://github.com/FluxML/Metalhead.jl).
The output is in `WHC[N]` format (width, height, color channels, batchsize).

```julia
using ImageNetDataset

dataset = ImageNet(:val)            # load validation set
X, y = dataset[1:5]                 # load features and targets

convert2image(dataset, X)           # convert features back to images

dataset.metadata["class_names"][y]  # obtain class names
```

### Custom preprocessing
The dataset can also be loaded in a custom size with custom normalization parameters
by configuring the `CenterCropNormalize` preprocessing transformation:
```julia
output_size = (224, 224)
mean = (0.485f0, 0.456f0, 0.406f0)
std  = (0.229f0, 0.224f0, 0.225f0)

transform = CenterCropNormalize(; output_size, mean, std)

dataset = ImageNet(:val; transform=transform)
```

Custom transformations can be implemented by extending `AbstractTransformation`.

### DataAugmentation.jl compatibility
Alternatively, ImageNetDataset is compatible with transformations from 
[DataAugmentation.jl](https://github.com/FluxML/DataAugmentation.jl/):

```julia
using ImageNetDataset, DataAugmentation

transform = CenterResizeCrop((224, 224)) |> ImageToTensor() |> Normalize(mean, std)  
dataset = ImageNet(:val; transform=transform)
```

> [!WARNING]
> Note that DataAugmentation.jl returns features in `HWC[N]` format instead of `WHC[N]`.

## Related packages

* [MLDatasets.jl](https://github.com/JuliaML/MLDatasets.jl): Utility package for accessing common Machine Learning datasets in Julia

> [!NOTE]
> This repository is based on [MLDatasets.jl PR #146](https://github.com/JuliaML/MLDatasets.jl/pull/146)
> and mirrors the MLDatasets API.
>
> Copyright (c) 2015 Hiroyuki Shindo and contributors.
