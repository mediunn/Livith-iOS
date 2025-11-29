.PHONY: module module-delete module-rollback generate clean

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
