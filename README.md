# Dragonfly Lossless Rotate

## NOTE

Tool jpegtran from MozJPEG may work incorrectly and not rotate same image many times.

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

By default gem use libjpeg binaries:
```shell
cjpeg
djpeg
jpegtran
pnmflip
```

But you can set MozJPEG binaries in ENV `CJPEG_BIN=mozjpeg-cjpeg` or in config:
```ruby
Dragonfly.app.configure
  require "dragonfly/lossless_rotate"
  plugin :lossless_rotate, cjpeg_bin: "mozjpeg-cjpeg",
                           djpeg_bin: "mozjpeg-djpeg",
                           jpegtran_bin: "mozjpeg-jpegtran"

end
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

libjpeg version 9b (17-Jan-2016)
libjpeg-turbo version 1.4.2 (build 20160222)
MozJPEG version 3.3.2 (build 20180713)

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

#### libjpeg

##### (optimize=true)
```bash
jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.240000   1.190000  10.600000 ( 11.368903)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.440000   1.640000  24.360000 ( 26.211808)
```

##### (optimize=false)
```bash
jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.290000   1.170000   9.600000 ( 10.321087)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.450000   1.470000  23.610000 ( 25.478872)
```

#### libjpeg-turbo

##### (optimize=true)
```bash
jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.280000   1.160000   9.170000 (  9.876645)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.560000   1.780000  22.710000 ( 23.879913)
```

##### (optimize=false)
```bash
jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.290000   1.170000   9.600000 ( 10.321087)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.450000   1.470000  23.610000 ( 25.478872)
```

#### MozJPEG

##### (optimize=true)
```bash
mozjpeg-jpegtran -rotate 90 -perfect -optimize old_path > new_path
```

```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.270000   1.110000  35.230000 ( 36.693039)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.550000   1.540000  48.880000 ( 50.171667)
```

##### (optimize=false)
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

#### libjpeg

##### (optimize=true)
```bash
djpeg old_path | pnmflip -r270 | cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.340000   0.930000  19.320000 ( 16.055059)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.390000   1.240000  32.520000 ( 30.055926)
```

##### (optimize=false)
```bash
djpeg old_path | convert - -rotate 90 JPG:new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.310000   1.450000  30.520000 ( 28.357557)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.530000   1.520000  43.790000 ( 41.732961)
```

#### libjpeg-turbo

##### (optimize=true)
```bash
djpeg old_path | pnmflip -r270 | cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.410000   1.280000  16.310000 ( 13.220535)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.310000   1.330000  30.300000 ( 28.332533)
```

##### (optimize=false)
```bash
djpeg old_path | convert - -rotate 90 JPG:new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.470000   1.110000  29.630000 ( 26.944807)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.500000   1.810000  43.420000 ( 42.309805)
```

#### MozJPEG

##### (optimize=true)
```bash
mozjpeg-djpeg old_path | pnmflip -r270 | mozjpeg-cjpeg -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.400000   1.150000  41.190000 ( 37.970843)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.420000   1.670000  55.700000 ( 52.835614)
```

##### (optimize=false)
```bash
mozjpeg-djpeg old_path | convert - -rotate 90 JPG:new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, optimize: false).apply } }
  0.270000   1.170000  31.300000 ( 28.983087)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, optimize: false).apply } }
  0.340000   1.310000  44.890000 ( 43.052428)
```
