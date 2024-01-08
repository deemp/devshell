# `devshell` options

## Available only in `Nix`

### `commands.<name>.*`

A config for command(s) when the `commands` option is an attrset.

**Type**: `(package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (nestedOptions) or (flatOptions)`

**Example value**:

```nix
{
  category = [
    {
      packages.grep = pkgs.gnugrep;
    }
    pkgs.python3
    [ "[package] vercel description" "nodePackages.vercel" ]
    "nodePackages.yarn"
  ];
}
```

**Declared in**:

- [nix/commands/types.nix](https://github.com/numtide/devshell/tree/main/nix/commands/types.nix)

### `commands.<name>.*.packages (nestedOptions)`

A nested (max depth is 100) attrset of `(flatOptions) package`-s
to describe in the devshell menu
and optionally bring to the environment.

A path to a leaf value is concatenated via `.`
and used as a `(flatOptions) name`.

A leaf value can be of three types.
  
1. When a `string` with a value `<string>`,
   devshell tries to resolve a derivation
   `pkgs.<string>` and use it as a `(flatOptions) package`.

2. When a `derivation`, it's used as a `(flatOptions) package`.

3. When a list with two elements:
   1. The first element is a `string`
      that is used to select a `(flatOptions) help`.
      - Priority of this `string` (if present) when selecting a `(flatOptions) help`: `4`.

        Lowest priority: `1`.
   2. The second element is interpreted as if
      the leaf value were initially a `string` or a `derivation`.
  
Priority of `package.meta.description` (if present in the resolved `(flatOptions) package`) 
when selecting a `(flatOptions) help`: 2

Lowest priority: `1`.

A user may prefer not to bring the environment some of the packages.

Priority of `expose = false` when selecting a `(flatOptions) expose`: `1`.

Lowest priority: `1`.

**Default value**:

```nix
{ }
```

**Type**: `null or ((nested (max depth is 100) attribute set of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]))))`

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.commands (nestedOptions)`

A nested (max depth is 100) attrset of `(flatOptions) command`-s
to describe in the devshell menu
and bring to the environment.

A path to a leaf value is concatenated via `.`
and used in the `(flatOptions) name`.

A leaf value can be of two types.
  
1. When a `string`, it's used as a `(flatOptions) command`.

2. When a list with two elements:
   1. the first element of type `string` with a value `<string>`
      that is used to select a `help`;

      Priority of the `<string>` (if present) when selecting a `(flatOptions) help`: `4`

      Lowest priority: `1`.
   1. the second element of type `string` is used as a `(flatOptions) command`.

**Default value**:

```nix
{ }
```

**Type**: `null or ((nested (max depth is 100) attribute set of (string or (list with two elements of types: [ string string ]))))`

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.expose (nestedOptions)`

When `true`, all `packages` can be added to the environment.

Otherwise, they can not be added to the environment,
but will be printed in the devshell description.

Priority of this option when selecting a `(flatOptions) expose`: `2`.

Lowest priority: `1`.

**Default value**:

```nix
false
```

**Type**: `null or boolean`

**Example value**:

```nix
{
  expose = true;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.exposes (nestedOptions)`

A nested (max depth is 100) attrset of `(flatOptions) expose`-s.

A leaf value can be used as `(flatOptions) expose` 
for a `(flatOptions) package` (`(flatOptions) command`)
with a matching path in `(nestedOptions) packages` (`(nestedOptions) commands`).

Priority of this option when selecting a `(flatOptions) expose`: `3`.

Lowest priority: `1`.

**Default value**:

```nix
{ }
```

**Type**: `null or ((nested (max depth is 100) attribute set of boolean))`

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  exposes.a.b = true;
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.help (nestedOptions)`

Priority of this option when selecting a `(flatOptions) help`: `1`.

Lowest priority: `1`.

**Default value**:

```nix
""
```

**Type**: `null or string`

**Example value**:

```nix
{
  help = "default help";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.helps (nestedOptions)`

A leaf value can be used as `(flatOptions) help`
for a `(flatOptions) package` (`(flatOptions) command`) 
with a matching path in `(nestedOptions) packages` (`(nestedOptions) commands`).

Priority of this option when selecting a `(flatOptions) help`: `3`.

Lowest priority: `1`.

**Default value**:

```nix
{ }
```

**Type**: `null or ((nested (max depth is 100) attribute set of string))`

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  helps.a.b = "run jq";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.prefix (nestedOptions)`

Possible `(flatOptions) prefix`.

Priority of this option when selecting a prefix: `1`.

Lowest priority: `1`.

**Default value**:

```nix
""
```

**Type**: `null or string`

**Example value**:

```nix
{
  prefix = "nix run .#";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.prefixes (nestedOptions)`

A leaf value becomes a `(flatOptions) prefix`
of a `package` (`command`) with a matching path in `packages` (`commands`).

Priority of this option when selecting a prefix: `2`.

Lowest priority: `1`.

**Default value**:

```nix
{ }
```

**Type**: `null or ((nested (max depth is 100) attribute set of string))`

**Example value**:

```nix
{
  packages.a.b = pkgs.jq;
  prefixes.a.b = "nix run ../#";
}
```

**Declared in**:

- [nix/commands/nestedOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/nestedOptions.nix)

### `commands.<name>.*.package (flatOptions)`

Used to bring in a specific package. This package will be added to the
environment.

**Default value**:

```nix
null
```

**Type**: `null or (package or string convertible to it) or package`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.category (flatOptions)`

Sets a free text category under which this command is grouped
and shown in the devshell menu.

**Default value**:

```nix
"[general commands]"
```

**Type**: `string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.command (flatOptions)`

If defined, it will add a script with the name of the command, and the
content of this value.

By default it generates a bash script, unless a different shebang is
provided.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
''
  #!/usr/bin/env python
  print("Hello")
''
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.expose (flatOptions)`

When `true`, the `(flatOptions) command` or the `(flatOptions) package` will be added to the environment.
  
Otherwise, they will not be added to the environment, but will be printed
in the devshell description.

**Default value**:

```nix
true
```

**Type**: `boolean`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.help (flatOptions)`

Describes what the command does in one line of text.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.name (flatOptions)`

Name of this command. 

Defaults to a `(flatOptions) package` name or pname if present.

The value of this option is required for a `(flatOptions) command`.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.<name>.*.prefix (flatOptions)`

Prefix of the command name in the devshell menu.

**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

## Available in `Nix` and `TOML`

### `commands`

Add commands to the environment.

**Default value**:

```nix
[ ]
```

**Type**: `(list of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (flatOptions))) or (attribute set of list of ((package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (nestedOptions) or (flatOptions)))`

**Example value**:

```nix
{
  "scripts" = [
    {
      commands.hello = [ "print hello" "echo hello" ];
      packages.awk = "gawk"
    }
    "yq-go"
    pkgs.jq
  ];
  "formatter" = [
    "nixpkgs-fmt"
  ];
}
```

**Declared in**:

- [modules/commands.nix](https://github.com/numtide/devshell/tree/main/modules/commands.nix)

### `commands.*`

A config for a command when the `commands` option is a list ("flat").

**Type**: `(package or string convertible to it) or (list with two elements of types: [ string (package or string convertible to it) ]) or (flatOptions)`

**Example value**:

```nix
[
  {
    category = "scripts";
    package = "black";
  }
  [ "[package] print hello" "hello" ]
  "nodePackages.yarn"
]
```

**Declared in**:

- [nix/commands/types.nix](https://github.com/numtide/devshell/tree/main/nix/commands/types.nix)

### `commands.*.package (flatOptions)`

Used to bring in a specific package. This package will be added to the
environment.

**Default value**:

```nix
null
```

**Type**: `null or (package or string convertible to it) or package`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.category (flatOptions)`

Sets a free text category under which this command is grouped
and shown in the devshell menu.

**Default value**:

```nix
"[general commands]"
```

**Type**: `string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.command (flatOptions)`

If defined, it will add a script with the name of the command, and the
content of this value.

By default it generates a bash script, unless a different shebang is
provided.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
''
  #!/usr/bin/env python
  print("Hello")
''
```

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.expose (flatOptions)`

When `true`, the `(flatOptions) command` or the `(flatOptions) package` will be added to the environment.
  
Otherwise, they will not be added to the environment, but will be printed
in the devshell description.

**Default value**:

```nix
true
```

**Type**: `boolean`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.help (flatOptions)`

Describes what the command does in one line of text.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.name (flatOptions)`

Name of this command. 

Defaults to a `(flatOptions) package` name or pname if present.

The value of this option is required for a `(flatOptions) command`.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `commands.*.prefix (flatOptions)`

Prefix of the command name in the devshell menu.

**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [nix/commands/flatOptions.nix](https://github.com/numtide/devshell/tree/main/nix/commands/flatOptions.nix)

### `devshell.packages`

The set of packages to appear in the project environment.

Those packages come from <https://nixos.org/NixOS/nixpkgs> and can be
searched by going to <https://search.nixos.org/packages>

**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.packagesFrom`

Add all the build dependencies from the listed packages to the
environment.

**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.interactive.<name>.deps`

A list of other steps that this one depends on.

**Default value**:

```nix
[ ]
```

**Type**: `list of string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.interactive.<name>.text`

Script to run.

**Type**: `string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.load_profiles`

Whether to enable load etc/profiles.d/*.sh in the shell.
**Default value**:

```nix
false
```

**Type**: `boolean`

**Example value**:

```nix
true
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.meta`

Metadata, such as 'meta.description'. Can be useful as metadata for downstream tooling.

**Default value**:

```nix
{ }
```

**Type**: `attribute set of anything`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.motd`

Message Of The Day.

This is the welcome message that is being printed when the user opens
the shell.

You may use any valid ansi color from the 8-bit ansi color table. For example, to use a green color you would use something like {106}. You may also use {bold}, {italic}, {underline}. Use {reset} to turn off all attributes.

**Default value**:

```nix
''
  {202}🔨 Welcome to devshell{reset}
  $(type -p menu &>/dev/null && menu)
''
```

**Type**: `string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.name`

Name of the shell environment. It usually maps to the project name.

**Default value**:

```nix
"devshell"
```

**Type**: `string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.prj_root_fallback`

If IN_NIX_SHELL is nonempty, or DIRENV_IN_ENVRC is set to '1', then
PRJ_ROOT is set to the value of PWD.

This option specifies the path to use as the value of PRJ_ROOT in case
IN_NIX_SHELL is empty or unset and DIRENV_IN_ENVRC is any value other
than '1'.

Set this to null to force PRJ_ROOT to be defined at runtime (except if
IN_NIX_SHELL or DIRENV_IN_ENVRC are defined as described above).

Otherwise, you can set this to a string representing the desired
default path, or to a submodule of the same type valid in the 'env'
options list (except that the 'name' field is ignored).

**Default value**:

```nix
{
  eval = "$PWD";
}
```

**Type**: `null or ((submodule) or non-empty string convertible to it)`

**Example value**:

```nix
{
  # Use the top-level directory of the working tree
  eval = "$(git rev-parse --show-toplevel)";
};
```

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.prj_root_fallback.eval`

Like value but not evaluated by Bash. This allows to inject other
variable names or even commands using the `$()` notation.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
"$OTHER_VAR"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.name`

Name of the environment variable
**Type**: `string`

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.prefix`

Prepend to PATH-like environment variables.

For example name = "PATH"; prefix = "bin"; will expand the path of
./bin and prepend it to the PATH, separated by ':'.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
"bin"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.unset`

Whether to enable unsets the variable.
**Default value**:

```nix
false
```

**Type**: `boolean`

**Example value**:

```nix
true
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.prj_root_fallback.value`

Shell-escaped value to set
**Default value**:

```nix
null
```

**Type**: `null or string or signed integer or boolean or package`

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `devshell.startup.<name>.deps`

A list of other steps that this one depends on.

**Default value**:

```nix
[ ]
```

**Type**: `list of string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `devshell.startup.<name>.text`

Script to run.

**Type**: `string`

**Declared in**:

- [modules/devshell.nix](https://github.com/numtide/devshell/tree/main/modules/devshell.nix)

### `env`

Add environment variables to the shell.

**Default value**:

```nix
[ ]
```

**Type**: `list of (submodule)`

**Example value**:

```nix
[
  {
    name = "HTTP_PORT";
    value = 8080;
  }
  {
    name = "PATH";
    prefix = "bin";
  }
  {
    name = "XDG_CACHE_DIR";
    eval = "$PRJ_ROOT/.cache";
  }
  {
    name = "CARGO_HOME";
    unset = true;
  }
]
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.eval`

Like value but not evaluated by Bash. This allows to inject other
variable names or even commands using the `$()` notation.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
"$OTHER_VAR"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.name`

Name of the environment variable
**Type**: `string`

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.prefix`

Prepend to PATH-like environment variables.

For example name = "PATH"; prefix = "bin"; will expand the path of
./bin and prepend it to the PATH, separated by ':'.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
"bin"
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.unset`

Whether to enable unsets the variable.
**Default value**:

```nix
false
```

**Type**: `boolean`

**Example value**:

```nix
true
```

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `env.*.value`

Shell-escaped value to set
**Default value**:

```nix
null
```

**Type**: `null or string or signed integer or boolean or package`

**Declared in**:

- [modules/env.nix](https://github.com/numtide/devshell/tree/main/modules/env.nix)

### `extra.locale.package`

Set the glibc locale package that will be used on Linux
**Default value**:

```nix
"pkgs.glibcLocales"
```

**Type**: `package`

**Declared in**:

- [extra/locale.nix](https://github.com/numtide/devshell/tree/main/extra/locale.nix)

### `extra.locale.lang`

Set the language of the project
**Default value**:

```nix
null
```

**Type**: `null or string`

**Example value**:

```nix
"en_GB.UTF-8"
```

**Declared in**:

- [extra/locale.nix](https://github.com/numtide/devshell/tree/main/extra/locale.nix)

### `git.hooks.enable`

Whether to enable install .git/hooks on shell entry.
**Default value**:

```nix
false
```

**Type**: `boolean`

**Example value**:

```nix
true
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.applypatch-msg.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.commit-msg.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.fsmonitor-watchman.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.post-update.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-applypatch.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-commit.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-merge-commit.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-push.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.pre-rebase.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `git.hooks.prepare-commit-msg.text`

Text of the script to install
**Default value**:

```nix
""
```

**Type**: `string`

**Declared in**:

- [extra/git/hooks.nix](https://github.com/numtide/devshell/tree/main/extra/git/hooks.nix)

### `language.c.compiler`

Which C compiler to use
**Default value**:

```nix
"pkgs.clang"
```

**Type**: `package or string convertible to it`

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.c.includes`

C dependencies from nixpkgs
**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.c.libraries`

Use this when another language dependens on a dynamic library
**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Declared in**:

- [extra/language/c.nix](https://github.com/numtide/devshell/tree/main/extra/language/c.nix)

### `language.go.package`

Which go package to use
**Default value**:

```nix
<derivation go-1.21.5>
```

**Type**: `package or string convertible to it`

**Example value**:

```nix
pkgs.go
```

**Declared in**:

- [extra/language/go.nix](https://github.com/numtide/devshell/tree/main/extra/language/go.nix)

### `language.go.GO111MODULE`

Enable Go modules
**Default value**:

```nix
"on"
```

**Type**: `one of "on", "off", "auto"`

**Declared in**:

- [extra/language/go.nix](https://github.com/numtide/devshell/tree/main/extra/language/go.nix)

### `language.perl.package`

Which Perl package to use
**Default value**:

```nix
<derivation perl-5.38.2>
```

**Type**: `package or string convertible to it`

**Example value**:

```nix
pkgs.perl538
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.perl.extraPackages`

List of extra packages (coming from perl5XXPackages) to add
**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Example value**:

```nix
[ perl538Packages.FileNext ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.perl.libraryPaths`

List of paths to add to PERL5LIB
**Default value**:

```nix
[ ]
```

**Type**: `list of string`

**Example value**:

```nix
[ ./lib ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/numtide/devshell/tree/main/extra/language/perl.nix)

### `language.ruby.package`

Ruby version used by your project
**Default value**:

```nix
"pkgs.ruby_3_2"
```

**Type**: `package or string convertible to it`

**Declared in**:

- [extra/language/ruby.nix](https://github.com/numtide/devshell/tree/main/extra/language/ruby.nix)

### `language.ruby.nativeDeps`

Use this when your gems depend on a dynamic library
**Default value**:

```nix
[ ]
```

**Type**: `list of (package or string convertible to it)`

**Declared in**:

- [extra/language/ruby.nix](https://github.com/numtide/devshell/tree/main/extra/language/ruby.nix)

### `language.rust.enableDefaultToolchain`

Enable the default rust toolchain coming from nixpkgs
**Default value**:

```nix
"true"
```

**Type**: `boolean`

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `language.rust.packageSet`

Which rust package set to use
**Default value**:

```nix
"pkgs.rustPlatform"
```

**Type**: `attribute set`

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `language.rust.tools`

Which rust tools to pull from the platform package set
**Default value**:

```nix
[
  "rustc"
  "cargo"
  "clippy"
  "rustfmt"
]
```

**Type**: `list of string`

**Declared in**:

- [extra/language/rust.nix](https://github.com/numtide/devshell/tree/main/extra/language/rust.nix)

### `serviceGroups`

Add services to the environment. Services can be used to group long-running processes.

**Default value**:

```nix
{ }
```

**Type**: `attribute set of (submodule)`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.description`

Short description of the service group, shown in generated commands

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.name`

Name of the service group. Defaults to attribute name in groups.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services`

Attrset of services that should be run in this group.

**Default value**:

```nix
{ }
```

**Type**: `attribute set of (submodule)`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services.<name>.command`

Command to execute.

**Type**: `string`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `serviceGroups.<name>.services.<name>.name`

Name of this service. Defaults to attribute name in group services.

**Default value**:

```nix
null
```

**Type**: `null or string`

**Declared in**:

- [modules/services.nix](https://github.com/numtide/devshell/tree/main/modules/services.nix)

### `services.postgres.package`

Which version of postgres to use
**Default value**:

```nix
"pkgs.postgresql"
```

**Type**: `package or string convertible to it`

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.createUserDB`

Create a database named like current user on startup.
This option only makes sense when `setupPostgresOnStartup` is true.

**Default value**:

```nix
true
```

**Type**: `boolean`

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.initdbArgs`

Additional arguments passed to `initdb` during data dir
initialisation.

**Default value**:

```nix
[
  "--no-locale"
]
```

**Type**: `list of string`

**Example value**:

```nix
[
  "--data-checksums"
  "--allow-group-access"
]
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)

### `services.postgres.setupPostgresOnStartup`

Whether to enable call setup-postgres on startup.
**Default value**:

```nix
false
```

**Type**: `boolean`

**Example value**:

```nix
true
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/numtide/devshell/tree/main/extra/services/postgres.nix)
