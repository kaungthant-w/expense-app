#!/bin/bash
# setup_build_scripts.sh - Set up proper permissions for build scripts

echo "🔧 Setting up build script permissions..."

# Make build scripts executable
chmod +x build_for_diawi.sh
chmod +x build_ipa.sh

echo "✅ Build scripts are now executable"
echo ""
echo "📋 Available build commands:"
echo "   ./build_for_diawi.sh    - Build IPA for Diawi distribution"
echo "   ./build_ipa.sh          - Standard IPA build"
echo ""
echo "🚀 You can now run: ./build_for_diawi.sh"
