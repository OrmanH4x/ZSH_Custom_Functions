
### Python check, activate and create virtual environment, can add dependencies check, or modify with venv used.

pyenv () {
	if [[ -n "$VIRTUAL_ENV" ]]
	then
		echo "Virtual environment active, deactivating..."
		deactivate
		return
	fi
	local env_dir=$(find . -maxdepth 1 -type d -name "*-env" | head -n 1)
	if [ -n "$env_dir" ]
	then
		echo "Virtual environment found ($env_dir), activating..."
		source "$env_dir"/bin/activate
	else
		local current_dir=${PWD##*/}
		local new_env="${current_dir}-env"
		echo "No virtual environment found, creating new one ($new_env)..."
		python3 -m venv "$new_env"
		source "$new_env"/bin/activate
	fi
}


 
### Ruby check, activate and create virtual environment, can add dependencies check, or modify with rbenv used.

rubenv () {
	if [[ -n "$RBENV_VERSION" ]]
	then
		echo "Ruby environment active, deactivating..."
		rbenv local --unset
		rbenv global system
		return
	fi
	if [ -f ".ruby-version" ]
	then
		local ruby_version=$(cat .ruby-version | tr -d '\n')
		echo "Ruby version found in .ruby-version ($ruby_version), activating..."
		if rbenv versions | grep -q "$ruby_version"
		then
			rbenv local "$ruby_version"
			echo "Ruby $ruby_version activated"
		else
			echo "Ruby $ruby_version is not installed. Would you like to install it? (y/n)"
			read -r response
			if [[ "$response" =~ ^[Yy]$ ]]
			then
				echo "Installing Ruby $ruby_version..."
				rbenv install "$ruby_version"
				rbenv local "$ruby_version"
				echo "Ruby $ruby_version installed and activated"
			else
				echo "Using system Ruby instead"
				rbenv local system
			fi
		fi
	else
		local current_dir=${PWD##*/}
		if [ -f "Gemfile" ]
		then
			local ruby_version=$(grep -E "^ruby\s+['\"]" Gemfile | head -1 | sed -E "s/.*['\"]([0-9.]+)['\"].*/\1/")
			if [ -n "$ruby_version" ]
			then
				echo "Found Ruby $ruby_version in Gemfile, checking installation..."
				if rbenv versions | grep -q "$ruby_version"
				then
					echo "Creating .ruby-version file with Ruby $ruby_version..."
					echo "$ruby_version" > .ruby-version
					rbenv local "$ruby_version"
					echo "Ruby $ruby_version activated"
				else
					echo "Ruby $ruby_version is not installed. Would you like to install it? (y/n)"
					read -r response
					if [[ "$response" =~ ^[Yy]$ ]]
					then
						echo "Installing Ruby $ruby_version..."
						rbenv install "$ruby_version"
						echo "$ruby_version" > .ruby-version
						rbenv local "$ruby_version"
						echo "Ruby $ruby_version installed and activated"
					else
						echo "Using system Ruby instead"
						rbenv local system
					fi
				fi
				return
			fi
		fi
		echo "No Ruby version specified in this directory."
		echo "Available Ruby versions:"
		rbenv versions
		echo -n "Enter Ruby version to use (or press Enter for system): "
		read -r ruby_version
		if [ -n "$ruby_version" ]
		then
			echo "$ruby_version" > .ruby-version
			rbenv local "$ruby_version"
			echo "Ruby $ruby_version activated"
		else
			echo "Using system Ruby"
			rbenv local system
		fi
	fi
}


tools () {
	echo -e "\n📂 AD Tool Directory Selector\n"
	local base_dir="$HOME/Downloads/Utils"
	if [[ ! -d "$base_dir" ]]
	then
		echo "❌ Directory not found: $base_dir"
		echo "   Please create the directory and add your tools"
		return 1
	fi
	local tool_dirs=()
	while IFS= read -r dir
	do
		tool_dirs+=("$dir")
	done < <(find "$base_dir" -maxdepth 1 -type d 2>/dev/null | grep -v "^$base_dir$" | sort)
	if [[ ${#tool_dirs[@]} -eq 0 ]]
	then
		echo "ℹ️  No  tool directories found in: $base_dir"
		echo "   Add your tools to this directory, for example:"
		return 1
	fi
	echo "🔍 Found ${#tool_dirs[@]} AD tools:"
	printf "   • %s\n" "${tool_dirs[@]##*/}" | sort
	local selected_dir=$(printf "%s\n" "${tool_dirs[@]}" | fzf --prompt="Select AD tool directory ➜ " --height=40% --reverse)
	if [[ -n "$selected_dir" ]]
	then
		echo "🚀 Changing to: $(basename "$selected_dir")"
		cd "$selected_dir"
		echo "📋 Contents:"
		lsd --group-dirs=first -la
	else
		echo "⏹️ Operation cancelled"
	fi
}



