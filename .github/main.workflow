workflow "Main" {
  on = "push"
  resolves = "Publish"
}

action "Install" {
  uses = "Culturehq/actions-bundler@master"
  args = "install"
}

action "Audit" {
  needs = "Install"
  uses = "Culturehq/actions-bundler@master"
  args = "exec bundle audit"
}

action "Lint" {
  needs = "Install"
  uses = "Culturehq/actions-bundler@master"
  args = "exec rubocop --parallel"
}

action "Test" {
  needs = "Install"
  uses = "Culturehq/actions-bundler@master"
  args = "exec rake test"
}

action "Tag" {
  needs = ["Audit", "Lint", "Test"]
  uses = "actions/bin/filter@master"
  args = "tag"
}

action "Publish" {
  needs = "Tag"
  uses = "Culturehq/actions-bundler@master"
  args = "build release:rubygem_push"
  secrets = ["BUNDLE_GEM__PUSH_KEY"]
}
