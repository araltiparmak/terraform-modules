# terraform-modules

Terraform module library. Other repos consume each module through
`github.com/araltiparmak/terraform-modules//<module>?ref=vX.Y.Z`, so a release
tag is a public contract.

## Releases

A release exists only when a commit on `main` carries a marker. Squash merges
turn the pull request title and body into that commit message, so the marker
goes there. `.github/scripts/release.sh` reads it; `README.md` lists the forms.

Choose the marker when you open or merge a pull request:

- `[release major]`: a consumer must change code. Renamed or removed module,
  renamed or removed variable or output, a higher minimum provider or
  Terraform version, changed defaults.
- `[release minor]`: new module, variable or output, with defaults that keep
  the old behaviour.
- `[release patch]`: bug fix with no interface change.
- No marker: docs, CI, tests, refactors.

Tags and releases come from the marker alone. Leave `git tag` and
`gh release create` to the script.

## Module rules

- Every module has `versions.tf` (`aws >= 6.0`, `terraform >= 1.9`) and
  `tests/*.tftest.hcl` that run on `mock_provider`.
- A new variable defaults to the existing behaviour, so a plain upgrade shows
  no plan diff. Renaming a resource adds a `moved` block.
- Changing a module updates its section in `README.md` in the same pull
  request.
- Before pushing, run what `.github/workflows/ci.yml` runs: `fmt`, `validate`
  and `test` for each module.

## GitHub Actions

Reference actions by official version tag (`actions/checkout@v7`), as
Dependabot keeps them current. Commit hashes stay out of workflows.
