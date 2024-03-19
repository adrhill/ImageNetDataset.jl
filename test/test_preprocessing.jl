using DataAugmentation

path = "assets/cat.jpg"

# Built-in transforms
tfm = CenterCropNormalize()
A = transform(tfm, path)
@test size(A) == (224, 224, 3)
@test_reference "references/CenterCropNormalize_default.txt" A
img = inverse_transform(tfm, A)
@test_reference "references/CenterCropNormalize_default_cat.txt" img

tfm = CenterCropNormalize(; output_size=(60, 40))
A = transform(tfm, path)
@test size(A) == (60, 40, 3)
@test_reference "references/CenterCropNormalize_100_50.txt" A
img = inverse_transform(tfm, A)
@test_reference "references/CenterCropNormalize_100_50_cat.txt" img

## Normalization
default_mean = (0.485f0, 0.456f0, 0.406f0)
default_std  = (0.229f0, 0.224f0, 0.225f0)

std = (1.0f0, 2.0f0, 3.0f0)
tfm = CenterCropNormalize(; output_size=(60, 40), std=std)
A = transform(tfm, path)
@test size(A) == (60, 40, 3)
@test_reference "references/CenterCropNormalize_100_50_std.txt" A
img = inverse_transform(tfm, A)
@test_reference "references/CenterCropNormalize_100_50_cat.txt" img # same as before

## RandomCropNormalize
tfm = RandomCropNormalize()
A = transform(tfm, path)
@test size(A) == (224, 224, 3)
img = inverse_transform(tfm, A)
@test size(img) == (224, 224)

tfm = RandomCropNormalize(; output_size=(60, 40))
A = transform(tfm, path)
@test size(A) == (60, 40, 3)
img = inverse_transform(tfm, A)
@test size(img) == (40, 60)

# DataAugmentations.jl
tfm = CenterResizeCrop((60, 40)) |> ImageToTensor() |> Normalize(default_mean, default_std)
A = transform(tfm, path)
@test size(A) == (60, 40, 3)
@test_reference "references/DataAugmentations.txt" A
