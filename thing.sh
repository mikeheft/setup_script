FILE=~/Desktop/setup_script/practice.sh
touch $FILE

cat > $FILE << 'EOF'
bundler
rails
EOF
