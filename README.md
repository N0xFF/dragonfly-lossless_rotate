# Dragonfly Lossless Rotate

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

## Usage
```ruby
@image.process(:lossless_rotate)
```

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

#### (optimize=true)
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
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, true, false).apply } }
  0.310000   1.100000  34.960000 ( 35.947432)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, true, false).apply } }
  0.470000   1.660000  49.050000 ( 50.823576)
```

### Fallback when jpegtran transformation is not perfect

Same image but resized to 556x417px

#### (decompresses=true, optimize=true)
```bash
mozjpeg-djpeg old_path | convert - -rotate 90 JPG:- | mozjpeg-jpegtran -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate).apply } }
  0.250000   1.230000  55.800000 ( 54.370212)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate).apply } }
  0.350000   1.590000  70.480000 ( 70.862372)
```

#### (decompresses=true, optimize=false)
```bash
mozjpeg-djpeg old_path | convert - -rotate 90 JPG: > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, true, false).apply } }
  0.280000   1.040000  30.130000 ( 27.274921)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, true, false).apply } }
  0.410000   1.380000  44.050000 ( 42.079892)
```

#### (decompresses=false, optimize=false)
```bash
convert old_path -rotate 90 JPG:new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, false, false).apply } }
  0.280000   1.380000  27.210000 ( 26.332910)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, false, false).apply } }
  0.580000   1.360000  40.410000 ( 40.420846)
```

#### (decompresses=false, optimize=true)
```bash
convert old_path -rotate 90 JPG:- | mozjpeg-jpegtran -optimize > new_path
```
```ruby
puts Benchmark.measure { 500.times { @image.process(:lossless_rotate, 90, false, true).apply } }
  0.310000   1.030000  62.320000 ( 60.490651)

puts Benchmark.measure { 500.times { @image.process(:safe_lossless_rotate, 90, false, true).apply } }
  0.330000   1.630000  75.350000 ( 73.732022)
```
