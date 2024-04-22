# 设置项目名称
NAME = nemu

# 如果make的目标不是clean，则执行以下代码块（忽略对make clean的检查）
ifneq ($(MAKECMDGOALS),clean)
# 默认使用x86指令集
ISA ?= x86
# 获取所有支持的指令集
ISAS = $(shell ls src/isa/)
# 输出正在构建的指令集名称
$(info Building $(ISA)-$(NAME))

# 检查指令集是否合法
ifeq ($(filter $(ISAS), $(ISA)), ) # ISA must be valid
$(error Invalid ISA. Supported: $(ISAS))
endif
endif

# 设置包含目录和构建目录
INC_DIR += ./include ./src/isa/$(ISA)/include
BUILD_DIR ?= ./build

# 如果定义了SHARE变量，则设置动态链接库相关参数
ifdef SHARE
SO = -so
SO_CFLAGS = -fPIC -D_SHARE=1
SO_LDLAGS = -shared -fPIC
endif

# 设置目标文件目录和可执行文件名称
OBJ_DIR ?= $(BUILD_DIR)/obj-$(ISA)$(SO)
BINARY ?= $(BUILD_DIR)/$(ISA)-$(NAME)$(SO)

# 包含Makefile.git中的内容
include Makefile.git

# 设置默认目标为app
.DEFAULT_GOAL = app

# 编译标志
CC = gcc
LD = gcc
INCLUDES  = $(addprefix -I, $(INC_DIR))
CFLAGS   += -O2 -MMD -Wall -Werror -ggdb3 $(INCLUDES) -D__ISA__=$(ISA) -fomit-frame-pointer

# 设置QEMU_DIFF_PATH和QEMU_SO路径
QEMU_DIFF_PATH = $(NEMU_HOME)/tools/qemu-diff
QEMU_SO = $(QEMU_DIFF_PATH)/build/$(ISA)-qemu-so

# 编译QEMU_SO
$(QEMU_SO):
	$(MAKE) -C $(QEMU_DIFF_PATH)

# 要编译的源文件和目标文件
SRCS = $(shell find src/ -name "*.c" | grep -v "isa")
SRCS += $(shell find src/isa/$(ISA) -name "*.c")
OBJS = $(SRCS:src/%.c=$(OBJ_DIR)/%.o)

# 编译模式
$(OBJ_DIR)/%.o: src/%.c
	@echo + CC $<
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(SO_CFLAGS) -c -o $@ $<

# 依赖关系
-include $(OBJS:.o=.d)

# 一些方便的规则
.PHONY: app run gdb clean run-env $(QEMU_SO)

# 编译目标
app: $(BINARY)

# 设置NEMU执行的参数
override ARGS ?= -l $(BUILD_DIR)/nemu-log.txt
override ARGS += -d $(QEMU_SO)

# 执行NEMU命令
IMG :=
NEMU_EXEC := $(BINARY) $(ARGS) $(IMG)

# 编译可执行文件
$(BINARY): $(OBJS)
	$(call git_commit, "compile")
	@echo + LD $@
	@$(LD) -O2 -rdynamic $(SO_LDLAGS) -o $@ $^ -lSDL2 -lreadline -ldl

# 运行NEMU
run-env: $(BINARY) $(QEMU_SO)

run: run-env
# $(call git_commit, "run")
	$(NEMU_EXEC)

# 调试NEMU
gdb: run-env
	$(call git_commit, "gdb")
	gdb -s $(BINARY) --args $(NEMU_EXEC)

# 清理构建目录
clean:
	-rm -rf $(BUILD_DIR)
	$(MAKE) -C tools/gen-expr clean
	$(MAKE) -C tools/qemu-diff clean
