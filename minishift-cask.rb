cask 'minishift' do
  version '1.26.1'
  sha256 '0e2cd654d8ccc1db8e75593edd4b630ab7861d1db1321387af9c854b7f8a3ee7'

  url "https://github.com/minishift/minishift/releases/download/v#{version}/minishift-#{version}-darwin-amd64.tgz"
  appcast 'https://github.com/minishift/minishift/releases.atom'
  name 'Minishift'
  homepage 'https://github.com/minishift/minishift'

  binary "minishift-#{version}-darwin-amd64/minishift"
end
