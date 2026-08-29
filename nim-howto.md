# Nim usage

The `sokol_shdc.nim` module integrates the bundled `sokol-shdc`
compiler with Nim build scripts such as `*.nimble` tasks or `build.nim`.
Copy the helper into your project and import it from the build script.

Example `sokol.nimble` task:

```nim
import std/os
import tools/sokol_shdc

task shaders, "Compile all shaders":
  let shaderDir = "examples/shaders"
  let buildDir = "build/shaders"

  let shaders = ["triangle"]
  var jobs: seq[ShaderOptions]

  for name in shaders:
    jobs.add ShaderOptions(
      shdcDir: "third_party/sokol-tools-bin",
      input: shaderDir / (name & ".glsl"),
      output: buildDir / (name & ".nim"),
      slang: "glsl430:metal_macos:hlsl5:glsl300es",
      bytecode: false
    )

  compileMany(jobs)
```

Run the task with:

```bash
nimble shaders
```

The helper selects the compiler for the host running Nimble, creates the
output directory, and generates Nim modules using `--format sokol_nim`.

The generated module can then be imported by the application using the
output directory in its Nim module search path.

The compiler is selected for the host running Nimble, not for the Nim target.
For example, an iOS build performed on macOS uses the macOS `sokol-shdc`
binary. Windows ARM64 and 32-bit Windows are rejected because this repository
contains only a Windows x86-64 binary.

The options correspond to the shader compiler features:

```nim
ShaderOptions(
  shdcDir: "third_party/sokol-tools-bin",
  input: "shaders/triangle.glsl",
  output: "build/shaders/triangle.nim",
  slang: "glsl430",
  defines: "USE_MOBILE:USE_FOG",
  module: "mobile",
  reflection: true,
  debuggable: true,
  bytecode: false,
  genver: 5
)
```

`bytecode` is disabled by default because Nim output is source code. The
`debuggable` option is available for parity with the other shader helpers.

For the complete compiler documentation, see the [official
`sokol-shdc` documentation](https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md).
