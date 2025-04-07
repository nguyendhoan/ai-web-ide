#!/bin/bash

echo "Đang kiểm tra môi trường..."

# Kiểm tra Node.js
if ! command -v node &> /dev/null; then
    echo "Không tìm thấy Node.js. Vui lòng cài đặt Node.js (phiên bản >= 18.18.0) từ https://nodejs.org/"
    exit 1
fi

# Kiểm tra phiên bản Node.js
node_version=$(node --version | cut -d 'v' -f 2)
node_major=$(echo $node_version | cut -d '.' -f 1)
node_minor=$(echo $node_version | cut -d '.' -f 2)

if [[ $node_major -lt 18 || ($node_major -eq 18 && $node_minor -lt 18) ]]; then
    echo "Phiên bản Node.js quá cũ. Cần phiên bản >= 18.18.0"
    echo "Phiên bản hiện tại: $node_version"
    exit 1
fi

echo "Node.js OK!"

# Gỡ bỏ cài đặt pnpm hiện tại và corepack
echo "Đang gỡ cài đặt pnpm hiện tại..."
npm uninstall -g pnpm &> /dev/null
npm uninstall -g corepack &> /dev/null

# Cài đặt pnpm mới
echo "Đang cài đặt pnpm mới..."
npm install -g pnpm --force
if [ $? -ne 0 ]; then
    echo "Không thể cài đặt pnpm. Sẽ dùng npm thay thế."
    USE_NPM=1
else
    echo "Đã cài đặt pnpm thành công!"
    USE_NPM=0
fi

# Kiểm tra node_modules
if [ ! -d "node_modules" ]; then
    echo "Đang cài đặt các dependencies..."
    if [ $USE_NPM -eq 0 ]; then
        pnpm install
        if [ $? -ne 0 ]; then
            echo "Lỗi khi dùng pnpm, thử dùng npm thay thế..."
            npm install
            if [ $? -ne 0 ]; then
                echo "Không thể cài đặt dependencies. Vui lòng thử lại sau."
                exit 1
            fi
        fi
    else
        npm install
        if [ $? -ne 0 ]; then
            echo "Không thể cài đặt dependencies. Vui lòng thử lại sau."
            exit 1
        fi
    fi
    echo "Đã cài đặt dependencies thành công!"
else
    echo "Dependencies OK!"
fi

echo "Đang khởi động ứng dụng..."
if [ $USE_NPM -eq 0 ]; then
    pnpm run dev --host
    if [ $? -ne 0 ]; then
        echo "Lỗi khi dùng pnpm, thử dùng npm thay thế..."
        npm run dev
    fi
else
    npm run dev
fi 