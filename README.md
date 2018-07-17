# Dragonfly Lossless Rotate

**About 60% more performance with libjpeg-turbo tools**

ImageMagick _convert_ command which used in Dragonfly for rotation is [lossy](https://www.imagemagick.org/discourse-server/viewtopic.php?t=5899) for JPEG images.
This gem uses _libjpeg_ for lossless rotation.

## NOTE

Tool _jpegtran_ from MozJPEG may work incorrectly and not rotate same image many times.
You should test it before run in production.

## Setup

```ruby
gem "dragonfly-lossless_rotate"
```

```ruby
Dragonfly.app.configure
  require "dragonfly/lossless_rotate"
  plugin :lossless_rotate
end
```

## Requirements

By default gem uses _libjpeg_ binaries and _pnmflip_ from _netpbm_:
```shell
cjpeg
djpeg
jpegtran
pnmflip
```

Ubuntu:
```bash
sudo apt-get install libjpeg-turbo-progs netpbm
```

macOS:
```bash
brew install libjpeg netpbm
```

FreeBSD:
https://www.freshports.org/graphics/libjpeg-turbo
https://www.freshports.org/graphics/netpbm

But you can set MozJPEG binaries in ENV `CJPEG_BIN=mozjpeg-cjpeg` or in config:
```ruby
Dragonfly.app.configure
  require "dragonfly/lossless_rotate"
  plugin :lossless_rotate, cjpeg_bin: "mozjpeg-cjpeg",
                           djpeg_bin: "mozjpeg-djpeg",
                           jpegtran_bin: "mozjpeg-jpegtran"

end
```

Use _pamflip_ as _pnmflip_ compatible binary:
```ruby
plugin :lossless_rotate, pnmflip_bin: "pamflip"
```

## Usage

JPEG only:
```ruby
@image.process(:lossless_rotate) # default 90
@image.process(:lossless_rotate, 180)
@image.process(:lossless_rotate, 270)
@image.process(:lossless_rotate, -90)
```

With fallback for other formats (rotate via ImageMagick):
```ruby
@image.process(:safe_lossless_rotate)
```

Other options:
```ruby
# Without JPEG optimization (default: true)
@image.process(:lossless_rotate, 90, optimize: false)
# Set default value
plugin :lossless_rotate, libjpeg_optimize: false

# Create progressive JPEG file (default: false)
@image.process(:lossless_rotate, 90, progressive: true)
# Set default value
plugin :lossless_rotate, libjpeg_progressive: true
```

## Benchmark

- _libjpeg-turbo_ version 1.4.2 (build 20160222)
- _MozJPEG_ version 3.3.2 (build 20180713)

JPEG 85KB 552x416px

### ImageMagick rotate
```bash
convert old_path -rotate 90 new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.rotate(90).apply } }
  0.360000   1.570000  25.270000 ( 25.168681)
```

### Lossless rotate

#### libjpeg-turbo

```bash
jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.280000   1.160000   9.170000 (  9.876645)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.560000   1.780000  22.710000 ( 23.879913)
```

#### MozJPEG

```bash
mozjpeg-jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.270000   1.110000  35.230000 ( 36.693039)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.550000   1.540000  48.880000 ( 50.171667)
```

### Fallback when jpegtran transformation is not perfect

> if the image dimensions are not a multiple of the iMCU size (usually 8 or 16 pixels)

Same image but resized to 556x417px

#### libjpeg-turbo

```bash
djpeg old_path | pnmflip -r270 | cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.410000   1.280000  16.310000 ( 13.220535)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.310000   1.330000  30.300000 ( 28.332533)
```

#### MozJPEG

```bash
mozjpeg-djpeg old_path | pnmflip -r270 | mozjpeg-cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.400000   1.150000  41.190000 ( 37.970843)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.420000   1.670000  55.700000 ( 52.835614)
```
