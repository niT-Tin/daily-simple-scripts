#!/bin/bash
# 配置
URL="http://127.0.0.1:8080"  # 替换为你的目标 URL
TOTAL_REQUESTS=10           # 总请求数
CONCURRENCY=1                # 并发数
DURATION=36                 # 持续时间（秒），1 小时 = 3600 秒
OUTPUT_FILE="results.json"    # 输出文件

# 确保输出文件是空的
> "$OUTPUT_FILE"

# 计算每个请求的间隔时间
INTERVAL=$((DURATION / TOTAL_REQUESTS))

# 定义请求函数
run_request() {
  local id=$1
  local timestamp=$(date +%s%N)
  echo "Request ID: $id, Timestamp: $timestamp" >> "$OUTPUT_FILE"
  curl -s "$URL" >> "$OUTPUT_FILE"
}

export -f run_request
export URL
export OUTPUT_FILE

start_time=$(date +%s)
# 使用 seq 生成请求序列，并通过 xargs 并发执行
seq "$TOTAL_REQUESTS" | xargs -n 1 -P "$CONCURRENCY" -I {} bash -c '
  # 计算当前请求的延迟时间
  echo 'sleep' $(('$INTERVAL'))s
  sleep $(('$INTERVAL'))s
  
  # 执行请求
  run_request {}
'
# 记录结束时间
end_time=$(date +%s)

# 计算总时间
elapsed=$((end_time - start_time))
echo "请求完成，花费时间: $elapsed 秒，结果保存在 $OUTPUT_FILE"
