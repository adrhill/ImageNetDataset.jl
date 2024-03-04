module ImageNetDataset

# This package is based on MLDatasets.jl PR 146
# https://github.com/JuliaML/MLDatasets.jl/pull/146
# and therefore reuses MIT licensed code and the API design from MLDatasets.
# Copyright (c) 2015 Hiroyuki Shindo and contributors.

using DataDeps
using ImageCore: channelview, colorview, AbstractRGB, RGB
using StackViews: StackView
using JpegTurbo
using MAT: matread # required to read metadata

include("preprocess.jl")
include("utils.jl")
include("imagenet.jl")

__init__() = __init__imagenet()

export AbstractPreprocessor, CenterCropNormalize
export ImageNet
end
