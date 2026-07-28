.PHONY: module module-delete module-rollback generate clean sync-dskit analyze

# 모듈 생성
module:
	@./Scripts/create_module.sh

# 모듈 삭제
module-delete:
	@./Scripts/delete_module.sh

# 모듈 삭제 롤백
module-rollback:
	@./Scripts/delete_module.sh

# Tuist generate
generate:
	@tuist generate

# Tuist clean
clean:
	@tuist clean

# DSKit 에셋 동기화
sync-dskit:
	@./Scripts/sync-dskit.sh

# Instruments trace 분석
analyze:
	@python3 ./Scripts/analyze_trace.py
