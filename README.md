# Dragonfly Lossless Rotate

## NOTE

Tool jpegtran from MozJPEG may work incorrectly and not rotate same image many times.
You should set ENV variable `JPEGTRAN_BIN=jpegtran` or `plugin :lossless_rotate, jpegtran_bin: "jpegtran"`

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

By default gem use libjpeg binaries from MozJPEG:
```shell
mozjpeg-cjpeg
mozjpeg-djpeg
mozjpeg-jpegtran
pnmflip
```

But you can set you own binaries in ENV or in `config/application.yml`:
```ruby
app.env[:cjpeg_bin]
app.env[:djpeg_bin]
app.env[:jpegtran_bin]
app.env[:pnmflip_bin]
```

## Usage

JPEG only:
```ruby
@image.process(:lossless_rotate) # default 90
@image.process(:lossless_rotate, 180)
@image.process(:lossless_rotate, 270)
@image.process(:lossless_rotate, -90)

# Without JPEG optimization
@image.process(:lossless_rotate, 90, optimize: false)
```

With fallback for other formats (rotate via ImageMagick):
```ruby
@image.process(:safe_lossless_rotate)
```

## Benchmark

### ImageMagick rotate
```bash
convert old_path -rotate 90 new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.rotate(90).apply } }
  0.360000   1.570000  25.270000 ( 25.168681)
```

### Lossless rotate

JPEG 85KB 552x416px

#### (optimize=true) MozJPEG
```bash
mozjpeg-jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.270000   1.110000  35.230000 ( 36.693039)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.550000   1.540000  48.880000 ( 50.171667)
```

#### (optimize=false)
```bash
mozjpeg-jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.310000   1.100000  34.960000 ( 35.947432)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.470000   1.660000  49.050000 ( 50.823576)
```

### Fallback when jpegtran transformation is not perfect

> if the image dimensions are not a multiple of the iMCU size (usually 8 or 16 pixels)

Same image but resized to 556x417px

#### (optimize=true) MozJPEG
```bash
mozjpeg-djpeg old_path | pnmflip -r270 | mozjpeg-cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.400000   1.150000  41.190000 ( 37.970843)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.420000   1.670000  55.700000 ( 52.835614)
```

#### (optimize=false)
```bash
mozjpeg-djpeg old_path | convert - -rotate 90 JPG:new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.270000   1.170000  31.300000 ( 28.983087)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.340000   1.310000  44.890000 ( 43.052428)
```
