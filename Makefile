h:
	@echo "Choose a node to make"
	@echo "---------------------------------"
	@echo " plo:  make node plo"
	@echo " rai:  make node rai"
	@echo " ani:  make node ani"
	@echo " cid:  make node cid"
	@echo " node: make local node"
	@echo ""
	@echo "Displays"
	@echo "---------------------------------"
	@echo " show: show details on this flake"

	# export LC_ALL=en_US.UTF-8 
	# # home-manager switch -b backup --flake ".#luis@ego" --experimental-features 'nix-command flakes' --show-trace
plo:
	home-manager switch --flake ".#luis@plo" --experimental-features 'nix-command flakes'

flor:
	home-manager switch -b backup --flake ".#gabi@flor" --experimental-features 'nix-command flakes'

ego:
	home-manager switch --flake ".#luis@ego" --extra-experimental-features nix-command --extra-experimental-features flakes

rai:
	home-manager switch --flake ".#ldesiqueira@rai" -b backup

ani:
	darwin-rebuild switch --flake ".#ani"
	brew bundle install

cid:
	darwin-rebuild switch --flake ".#cid"

burgundy:
	home-manager switch --flake ".#burgundy"

tupa:
	home-manager switch --flake ".#tupa"

# lucas pereira laptop
LILU:
	home-manager switch --flake ".#LILU"

node:
	build

show:
	nix flake show
