#!/system/bin/sh
##########################################################################################
#
# Hide Root Permission Script
# by CoolAPK@抱紧我的玄黑黑鲨4S
# by Github@WYing-CCC (无影.)
# by Kwai@WYing.
# 
##########################################################################################
##########################################################################################
#
# This is a Hide Root Permission Script Android Shell Script Source Code
# 
##########################################################################################
##########################################################################################
# Instructions:
#
# 1. You Can use this script hide root
# 2. Flash the module 
# 3. Enable debugging
# 4. Hide the abnormal environment where root - detection software operates.
# 5. Currently supported root software: Magisk29000 MagiskAlpha29001 Kitsune 27002 MagiskCanary28000 APatch11071 APatchNext11021 KernelSU12081 KernelSUNext12490
#
##########################################################################################



# 设置终端颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'
TRUE_ORANGE='\033[38;2;255;165;0m'  # 真正的橙色（需要终端支持）
NC='\033[0m'                 # 重置颜色

LIGHT_BLUE='\033[0;94m'
LIGHT_GREEN='\033[0;92m'
LIGHT_YELLOW='\033[0;93m'
LIGHT_MAGENTA='\033[0;95m'
LIGHT_CYAN='\033[0;96m'
LIGHT_RED='\033[0;91m'
TRUE_ORANGE='\033[38;2;255;165;0m'  # 真正的橙色（需要终端支持）
# 示例输出
echo -e "${ORANGE}浅橙色（近似）${NC}"
echo -e "${TRUE_ORANGE}真正的橙色（需要终端支持）${NC}"

# 示例输出
echo -e "${ORANGE}浅橙色（近似）${NC}"
echo -e "${TRUE_ORANGE}真正的橙色（需要终端支持）${NC}"

# 常量定义

YC_DIR=/data/local/yc
CONFIG_ZIP=$YC_DIR/config.zip
APK_ZIP=$YC_DIR/apk.zip
MODULE_ZIP=$YC_DIR/Modules.zip
JZMK_ZIP=$YC_DIR/jzmk.zip
APCONFIG=$YC_DIR/package_config
MOMO_SH=$YC_DIR/momo.sh
KEYBOX_SH=$YC_DIR/keybox.sh
MODULES_ZIP="$YC_DIR/Modules.zip"
Loop_ZIP="$YC_DIR/Loop.zip"
ART_ZIP="$YC_DIR/ART.zip"
INIT_RC_ZIP="$YC_DIR/Init_rc.zip"
SELINUX_ZIP="$YC_DIR/Selinux.zip"
DNP_ZIP="$YC_DIR/DNP.zip"
# URL定义
MODULES_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/Module.zip"
JZMK_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/jzmk.zip"
CONFIG_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/config.zip"
APK_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/installapk.zip"
APCONFIG_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/package_config"
HIDE_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/hide.sh"
MOMO_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/momo.sh"
Loop_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/000.zip"
KEYBOX_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/keybox.sh"
ART_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/ART.zip"
INIT_RC_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/Init_rc.zip"
SELINUX_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/Selinux.zip"
DNP_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/DNP.zip"

# 创建目录

mkdir -p $YC_DIR
mkdir -p $MODULE_DIR
mkdir -p "/data/HRPS"
mkdir -p "/data/HRPS/Debug_Log"

# 日志函数
log() {
    echo -e "${GREEN}[LOG]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}













# 特殊下载方法实现
openssl_download() {
    local hostport=$(echo "$1" | sed 's|https://||; s|/.*||; s/:/ /')
    local path=$(echo "$1" | sed 's|https://[^/]*||')
    {
        echo -e "GET $path HTTP/1.1\r\nHost: ${hostport%% *}\r\nUser-Agent: $user_agent\r\nConnection: close\r\n\r\n"
        sleep "$timeout"
    } | openssl s_client -quiet -connect "$hostport" 2>/dev/null | sed '1,/^\r$/d' > "$2"
}

bash_raw_download() {
    local hostport=$(echo "$1" | sed 's|.*://||; s|/.*||; s/:/ /')
    local path=$(echo "$1" | sed 's|.*://[^/]*||')
    exec 3<>/dev/tcp/${hostport/ /\/} && {
        echo -e "GET $path HTTP/1.1\r\nHost: ${hostport/ */}\r\n\r\n" >&3
        timeout "$timeout" cat <&3 | sed '1,/^\r$/d' > "$2"
    }
}


download_file() {
    local url=$1
    local output=$2
    local output_dir=$(dirname "$output")
    local max_retry=3
    local timeout=30
    local retry_count=0
    local user_agent="Mozilla/5.0 (compatible; ScriptDownloader/1.0)"


    # 1. 创建目录
    mkdir -p "$output_dir" || {
        error "目录创建失败: $output_dir (权限问题?)"
        return 1
    }

    # 2. 多工具尝试下载
    while [ $retry_count -lt $max_retry ]; do
        # 工具优先级排序（从最优到最基础）
        if command -v aria2c >/dev/null; then
            aria2c -x16 -s16 -k1M --timeout=$timeout -U "$user_agent" -o "$output" "$url" && break
        elif command -v axel >/dev/null; then
            axel -n 8 -T $timeout -U "$user_agent" -o "$output" "$url" && break
        elif command -v wget >/dev/null; then
            wget ${WGET_OPTS} -T $timeout -U "$user_agent" -O "$output" "$url" && break
        elif command -v curl >/dev/null; then
            curl --progress-bar -L --connect-timeout $timeout -A "$user_agent" -o "$output" "$url" && break
        elif command -v http >/dev/null; then
            http --timeout $timeout -d "$url" > "$output" && break
        elif command -v fetch >/dev/null; then
            fetch -T $timeout -o "$output" "$url" && break
        elif command -v lftp >/dev/null; then
            lftp -c "set net:timeout $timeout; get $url -o $output" && break
        elif command -v python >/dev/null; then
            python -c "import urllib.request; urllib.request.urlretrieve('$url', '$output')" && break
        elif command -v openssl >/dev/null && [[ "$url"   ]]; then
            openssl_download "$url" "$output" && break
        elif [ -e /dev/tcp ]; then
            bash_raw_download "$url" "$output" && break
        else
            error "无可用下载工具！请安装 aria2c/wget/curl 等"
            return 1
        fi

        retry_count=$((retry_count+1))
        log "下载失败，第 $retry_count 次重试..."
        sleep 2
    done

    # 3. 结果验证
    if [ $retry_count -eq $max_retry ]; then
        error "下载失败: $url (已尝试 $max_retry 次)"
        rm -f "$output"
        return 1
    fi

    [ -s "$output" ] || {
        error "文件为空或损坏: $output"
        rm -f "$output"
        return 1
    }

    log "下载成功! 大小: $(du -h "$output" | cut -f1), 校验: $(md5sum "$output" | cut -d' ' -f1)"
    return 0
}




# 安装模块函数
install_module() {
    local module_path=$1
    
    if [ ! -f "$module_path" ]; then
        error "模块文件不存在: $module_path"
        return 1
        rm -rf $YC_DIR/
    fi
    
    if [ -d "/data/adb/ap" ]; then
        log "检测到APatch环境，安装模块..."
        apd module install "$module_path"
    elif [ -d "/data/adb/ksu" ]; then
        log "检测到KernelSU环境，安装模块..."
        ksud module install "$module_path"
    elif [ -d "/data/adb/magisk" ]; then
        log "检测到Magisk环境，安装模块..."
        magisk --install-module "$module_path"
    else
        error "未检测到支持的ROOT环境"
        return 1
    fi
    
    return $?
    rm -rf $YC_DIR/
}

# 显示操作菜单
show_options_menu() {
    echo ""
    echo -e "${GREEN}请选择后续操作：${NC}"
    echo "[1] 返回主菜单"
    echo "[2] 退出脚本"
    echo "[3] 重启手机"
    read choice
    
    case $choice in
        1) 
            clear
            main_b
            ;;
        2)
            log "脚本即将退出..."
            exit 0
            ;;
        3)
        sleep 3
        reboot
        ;;
        *)
            warn "无效输入，返回主菜单"
            sleep 1
            clear
            main
            ;;
    esac
}

# 救砖模块菜单
show_jzmk_menu() {
    while true; do
        echo -e "${GREEN}请输入数值：${NC}"
        echo "${GREEN}[1] 安装救砖模块${NC}"
        echo "${GREEN}[2] 不安装救砖模块${NC}"
        
        read input
        
        if [ -z "$input" ]; then
            warn "输入不能为空，请重新输入！"
            continue
        fi

        case $input in
            1)
                log "开始下载救砖模块..."
                if download_file "$JZMK_URL" "$JZMK_ZIP"; then
                    if install_module "$JZMK_ZIP"; then
                        echo ""
                        warn "记住！开机时："
                        warn "音量+ 禁用所有系统模块"
                        warn "音量- 禁用所有系统模块（包括LSP模块）"
                        warn "重要的事情说三遍！眼盲不要怪作者！"
                    else
                        error "救砖模块安装失败"
                    fi
                fi
                show_options_menu
                return
                ;;
            2)
                log "跳过救砖模块安装"
                show_options_menu
                return
                ;;
            *)
                warn "输入无效"
                ;;
        esac
    done
}

# 删除模块菜单
show_delete_modules_menu() {
    while true; do
        echo -e "${GREEN}请输入数值：${NC}"
        echo "${GREEN}[1] 删除所有模块${NC}"
        echo "${GREEN}[2] 保留所有模块（可能导致隐藏效果不好）${NC}"
        read input
        
        if [ -z "$input" ]; then
            warn "输入不能为空，请重新输入！"
            continue
        fi

        case $input in
            1)
                log "开始删除所有模块..."
                rm -rf /data/adb/modules/
                rm -rf /data/adb/modules-update/
                rm -rf /data/adb/lspd/
                rm -rf /data/adb/tricky_store/
                rm -rf /data/adb/zygisksu
                log "模块删除完成"
                return
                ;;
            2)
                log "保留所有模块"
                return
                ;;
            *)
                warn "输入无效"
                ;;
        esac
    done
}

# 显示设备信息
show_device_info() {
    clear
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo ""
    echo "－品牌: $(getprop ro.product.brand)"
    echo "－代号: $(getprop ro.product.device)"
    echo "－模型: $(getprop ro.product.model)"
    echo "－安卓版本: $(getprop ro.build.version.release)"
    test -n "$(getprop ro.miui.ui.version.name)" && echo "－MIUI版本: MIUI $(getprop ro.miui.ui.version.name) - $(getprop ro.build.version.incremental)"
    echo "－内核版本: $(uname -a)"
    echo "－运存大小: $(free -m | grep "Mem" | awk '{print $2}')MB  已用:$(free -m | grep "Mem" | awk '{print $3}')MB  剩余:$(( $(free -m | grep "Mem" | awk '{print $2}') - $(free -m | grep "Mem" | awk '{print $3}') ))MB"
    echo "－Swap大小: $(free -m | grep "Swap" | awk '{print $2}')MB  已用:$(free -m | grep "Swap" | awk '{print $3}')MB  剩余:$(free -m | grep "Swap" | awk '{print $4}')MB"
    echo ""
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    show_options_menu
}

#!/system/bin/sh
# 配置隐藏应用列表 (完全兼容版)
configure_hidden_apps() {
    # 禁用所有可能出错的语法

    
    # 1. 下载检测
    echo "正在下载..."
    if download_file "$CONFIG_URL" "$CONFIG_ZIP"; then
        echo "下载验证通过"
    else
        echo "错误：下载失败" >&2
        return 1
    fi

    # 2. 解压执行 (POSIX标准写法)
    for dir in \
        "/data/user/0/com.google.android.hmal/" \
        "/data/user/0/com.tsng.hidemyapplist/" \
        "/data/user/0/com.tencent.wifimanager/"
    do
        if unzip -o "$CONFIG_ZIP" -d "$dir" >/dev/null 2>&1; then
            echo "[OK] $dir"
        else
            echo "[FAILED] $dir" >&2
        fi
    done

    # 3. 结果清理
    rm -rf $YC_DIR/
    echo "操作完成"
}




# 隐藏功能菜单
hide_menu() {
    while true; do
        clear
        echo -e "${YELLOW}[1] 切换Shamiko模式${NC}"
        echo -e "${YELLOW}[2] 过MoMo各种环境问题${NC}"
        echo -e "${GREEN}[3] Hunter: Find Root:Loop28-34${NC}"
        echo -e "${GREEN}[4] Native Detector 检测到泄露的Keybox${NC}"
        echo -e "${YELLOW}[5] 解决Native Test的问题${NC}"
        echo -e "${GREEN}[6] 返回主菜单${NC}"
        
        read choice
        
        case $choice in
            1)
                if [ -f /data/adb/shamiko/whitelist ]; then
                    rm -f /data/adb/shamiko/whitelist
                    echo "- Shamiko已设置黑名单模式"
                else
                    touch /data/adb/shamiko/whitelist
                    echo "- Shamiko已设置白名单模式"
                fi
                show_options_menu
                ;;
            2)
                clear
                # 处理Momo环境问题
                Momo_hidemenu
                
                ;;
            3)
                clear
                # 安装000模块
                local module_path="$YC_DIR/000.zip"
                log "开始下载000模块..."
                if download_file "$Loop_URL" "$Loop_ZIP"; then
                    if install_module "$Loop_ZIP"; then
                        log "000模块安装成功"
                        rm -rf $YC_DIR/
                    else
                        error "000模块安装失败"
                        rm -rf $YC_DIR/
                    fi
                else
                    error "000模块下载失败"
                    rm -rf $YC_DIR/
                fi
                show_options_menu
                ;;
            4)
                clear
                # 检查并下载keybox.sh
                if [ ! -f "$KEYBOX_SH" ]; then
                    log "keybox.sh不存在，开始下载..."
                    if download_file "$KEYBOX_URL" "$KEYBOX_SH"; then
                        chmod 777 "$KEYBOX_SH"
                        rm -rf $YC_DIR/
                    else
                        error "keybox.sh下载失败"
                        rm -rf $YC_DIR/
                        show_options_menu
                        continue
                    fi
                fi
                # 执行keybox.sh
                su -c "sh $KEYBOX_SH"
                show_options_menu
                ;;
            5)
                clear
                # 解决Native Test问题
                Native_Test_Menu
                ;;
            6)
                clear
                main
                ;;
            *)
                warn "输入无效"
                sleep 1
                ;;
        esac
    done
}

Momo_hidemenu(){
echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
echo "Momo过环境"
echo "[${GREEN}f${NC}] ${YELLOW}返回主界面${NC}"
echo "[${GREEN}1${NC}] ${YELLOW}设备正在运行非原厂系统${NC}"
echo "[${GREEN}2${NC}] ${YELLOW}找到TWRP或Magisk等可疑文件${NC}"
echo "[${GREEN}3${NC}] ${YELLOW}包管理服务异常${NC}"
echo "[${GREEN}4${NC}] ${YELLOW}数据未加密，挂在参数被修改${NC}"
echo "[${GREEN}5${NC}] ${YELLOW}ART参数异常${NC}"
echo "[${GREEN}6${NC}] ${YELLOW}init.rc 被修改${NC}"
echo "[${GREEN}7${NC}] ${YELLOW}Selinux为宽容模式/init.rc被修改/处于调试环境(部分rom可能无效)${NC}"
echo "[${GREEN}8${NC}] ${YELLOW}非 SDK 接口的限制失效${NC}"
echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
echo -e "${GREEN}请输入选择：${NC}"
    read choice
            case $choice in
                    1)
                        echo "正在删除官改/第三方系统留在system分区的残渣..."
                                             rm -rf /system/addon.a
                                                         rm -rf /system/addon.b
                                                                     rm -rf /system/addon.c
                                                                                 rm -rf /system/addon.d
                    ;;        
                        2)            
                        echo "清理残渣中..."            
                        echo "（如果你是小米奇迹的TWRP，可以在TWRP内将TWRP文件夹改成别的）"            
                        rm -rf /sdcard/TWRP/            
                        ;;        
                        3)            
                        echo "这个暂时不能全自动隐藏"            
                        echo "请手动打开核心破解/Cemiuiler/HyperCilier中关闭[禁用软件包管理器签名验证]"            
                        ;;        
                        4)            
                        clear
                # 安装ART模块
                
                log "开始下载隐藏数据未加密，挂在参数被修改模块..."
                if download_file "$DNP_URL" "$DNP_ZIP"; then
                    if install_module "$DNP_ZIP"; then
                        log "模块安装成功"
                        rm -rf $YC_DIR/
                    else
                        error "模块安装失败"
                        rm -rf $YC_DIR/
                    fi
                else
                    error "模块下载失败"
                    rm -rf $YC_DIR/
                fi
                show_options_menu
                        ;;
                        5)            
                        clear
                # 安装ART模块
                
                log "开始下载ART模块..."
                if download_file "$ART_URL" "$ART_ZIP"; then
                    if install_module "$ART_ZIP"; then
                        log "ART模块安装成功"
                        rm -rf $YC_DIR/
                    else
                        error "ART模块安装失败"
                        rm -rf $YC_DIR/
                    fi
                else
                    error "ART模块下载失败"
                    rm -rf $YC_DIR/
                fi
                show_options_menu
                            ;;
                        6)
                                        # 安装模块
                
                log "开始下载隐藏init.rc被修改模块..."
                if download_file "$INIT_RC_URL" "$INIT_RC_ZIP"; then
                    if install_module "$INIT_RC_ZIP"; then
                        log "模块安装成功"
                        rm -rf $YC_DIR/
                    else
                        error "模块安装失败"
                        rm -rf $YC_DIR/
                    fi
                else
                    error "模块下载失败"
                    rm -rf $YC_DIR/
                fi
                show_options_menu
                        
                            ;;
                        7)
                                        # 安装ART模块
                
                log "开始下载隐藏Selinux模块..."
                if download_file "$SELINUX_URL" "$SELINUX_ZIP"; then
                    if install_module "$SELINUX_ZIP"; then
                        log "模块安装成功"
                        rm -rf $YC_DIR/
                    else
                        error "模块安装失败"
                        rm -rf $YC_DIR/
                    fi
                else
                    error "模块下载失败"
                    rm -rf $YC_DIR/
                fi
                show_options_menu
                        
                            ;;
                        8)
                        settings delete global hidden_api_policy
                        settings delete global hidden_api_policy_p_apps
                        settings delete global hidden_api_policy_pre_p_apps
                        settings delete global hidden_api_blacklist_exemp
                        echo "隐藏成功！"
                        exit 0
                            ;;
                        f)            
                        clear            
                        main            
                        ;;        
                        *)            
                        clear            
                        main            
                        ;;    
                        esac
}

Native_Test_Menu(){
echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
PIF_DIR=$YC_DIR/pif.zip
PIF_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/PlayIntegrityFix.zip"
LSP_DIR="$YC_DIR/LSP.zip"
LSP_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/LSP.zip"
ZN_DIR="$YC_DIR/ZygiskNext.zip"
ZN_URL="https://gh.llkk.cc/https://github.com/WYing-CCC/WYing-HRPS/releases/download/Download/ZygiskNext.zip"
echo "过Native Test环境"
echo "[${GREEN}f${NC}] ${YELLOW}返回主界面${NC}"
echo "[${GREEN}1${NC}] ${YELLOW}Conventional Tests(1)${NC}"
echo "[${GREEN}2${NC}] ${YELLOW}Conventional Tests (3)${NC}"
echo "[${GREEN}3${NC}] ${YELLOW}Evil Service (2)${NC}"
echo "[${GREEN}4${NC}] ${YELLOW}Found Injection${NC}"
echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
echo -e "${GREEN}请输入选择：${NC}"
    read choice
            case $choice in
                    1)
                         if download_file "$PIF_URL" "$PIF_ZIP"; then
                         install_module "$PIF_ZIP"
                         fi
                         show_options_menu
                         ;;
                         2)
                            if download_file "$LSP_URL" "$LSP_ZIP"; then
                            install_module "$LSP_ZIP"
                            fi
                            show_options_menu
                         ;;
                         3)
                         if download_file "$LSP_URL" "$LSP_ZIP"; then
                         install_module "$LSP_ZIP"
                         fi
                         show_options_menu
                         ;;
                         4)
                         if download_file "$ZN_URL" "$ZN_ZIP"; then
                         install_module "$ZN_ZIP"            
                         fi
                         show_options_menu
                         
                         ;;
                         f)
                         clear
                         main
                         ;;
                         *)
                         clear
                         main
                         ;;
                         esac
                         }




Test_Root() {
    # 获取su版本信息（兼容APatch/KernelSU/Magisk）
    SU_VERSION=$(su -v 2>/dev/null || su -V 2>/dev/null || echo "")
    SU_VERSION_NUM=$(su -V 2>/dev/null || echo "")
#APatch/APatchNext
# 执行 su -v 命令并捕获输出
su_v_output=$(su -v 2>&1)

# 检查输出中是否包含 "APatch"
if echo "$su_v_output" | grep -q "APatch"; then
    # 如果包含 APatch，则执行 su -V 命令并捕获输出
    su_V_output=$(su -V 2>&1)
    
    # 检查版本号是否是 11008、11010 或 11021
    if echo "$su_V_output" | grep -qE "11008|11010|11021"; then
        echo "${YELLOW}你的Root管理器为：${NC}APatchNext $(su -V)"
    else
        echo "${YELLOW}你的Root管理器为：${NC}APatch $(su -V)"
    fi
fi
    
    # 检查KernelSU/KernelSUNext/Sukisu Ultra
    if [ -d "/data/adb/ksud" ]; then
        if [ -d "/data/user/0/me.weishu.kernelsu/" ]; then
        echo "${YELLOW}你的Root管理器为：${NC}KernelSU $SU_VERSION_NUM"
        elif [ -d "/data/user/0/com.rifsxd.ksunext/" ]; then
        echo "${YELLOW}你的Root管理器为：${NC}KernelSUNext $SU_VERSION_NUM"
        elif [ -d "com.sukisu.ultra" ]; then
        echo "${YELLOW}你的Root管理器为：${NC}SukiSU Ultra $SU_VERSION_NUM"
        return
        fi
    fi

    # 检查Magisk Alpha/Kitsune Mask
    if echo "$SU_VERSION" | grep -qi "alpha"; then
        echo "${YELLOW}你的Root管理器为：${NC}Magisk Alpha $SU_VERSION_NUM"
    elif echo "$SU_VERSION" | grep -qi "kitsune"; then
        echo "${YELLOW}你的Root管理器为：${NC}Kitsune Mask $SU_VERSION_NUM"
    elif echo "$SU_VERSION" | grep -qi "magisk"; then
        echo "${YELLOW}你的Root管理器为：${NC}Magisk $SU_VERSION_NUM"
    fi
}



#Install_Modules(){
#    if download_file "$MODULES_URL" "$MODULES_ZIP"; then
#        install_module "$MODULES_ZIP"
#        show_options_menu
#        else
#        error 安装失败
#        show_options_menu
#    fi
#}

Module_Install(){
download_file "$MODULES_URL" "$MODULES_ZIP"
#!/system/bin/sh

# 获取当前时间并格式化为年.月.日.时.分.秒
LOG_TIME=$(date +"%Y.%m.%d.%H.%M.%S")

# 定义日志文件名
LOG_FILE="/data/HRPS/Debug_Log/${LOG_TIME}_Module_Install.log"

# 初始化日志变量
LOG_OUTPUT=""

# 记录开始安装模块的信息
LOG_OUTPUT+="开始安装模块: $(date)\n"

# 安装 Magisk 模块（正确命令：magisk --install-module）

if command -v magisk &> /dev/null; then
    LOG_OUTPUT+="magisk 命令已找到，开始安装...\n"
    LOG_OUTPUT+="正在安装 Magisk 模块...\n"
    if magisk --install-module $MODULES_ZIP 2>&1 | while read -r line; do
        LOG_OUTPUT+="$line\n"
        echo "$line"  # 实时显示到终端
    done; then
        LOG_OUTPUT+="[成功] Magisk 模块安装完成\n"
    else
        LOG_OUTPUT+="[失败] Magisk 模块安装失败，请检查日志\n"
    fi
fi

# 安装 APatch 模块（正确命令：apd module install）

if command -v apd &> /dev/null; then
    LOG_OUTPUT+="apd 命令已找到，开始安装 APatch 模块...\n"
    LOG_OUTPUT+="正在安装 APatch 模块...\n"
    if apd module install $MODULES_ZIP 2>&1 | while read -r line; do
        LOG_OUTPUT+="$line\n"
        echo "$line"  # 实时显示到终端
    done; then
        LOG_OUTPUT+="[成功] APatch 模块安装完成\n"
    else
        LOG_OUTPUT+="[失败] APatch 模块安装失败，请检查日志\n"
    fi
fi

# 安装 KernelSU 模块（正确命令：ksud module install）

if command -v ksud &> /dev/null; then
    LOG_OUTPUT+="ksud 命令已找到，开始安装 KernelSU 模块...\n"
    LOG_OUTPUT+="正在安装 KernelSU 模块...\n"
    if ksud module install $MODULES_ZIP 2>&1 | while read -r line; do
        LOG_OUTPUT+="$line\n"
        echo "$line"  # 实时显示到终端
    done; then
        LOG_OUTPUT+="[成功] KernelSU 模块安装完成\n"
    else
        LOG_OUTPUT+="[失败] KernelSU 模块安装失败，请检查日志\n"
    fi
fi

# 记录安装完成的信息
LOG_OUTPUT+="模块安装完成: $(date)\n"

# 提示日志文件位置（终端显示）
echo "日志已保存到: $LOG_FILE"
echo "$LOG_OUTPUT"  # 终端实时显示所有输出

# 将所有输出写入日志文件
echo -e "$LOG_OUTPUT" > "$LOG_FILE"
}


main_b(){
echo -e "${NC}"
    sleep 0.025
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    sleep 0.025
    echo -e "${RED}AHideV3开源${NC}"
    sleep 0.025
    echo -e "${RED}by${NC} ${GREEN} Github@WYing-CCC (无影.)${NC}"
    sleep 0.025
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    sleep 0.025
            Test_Root
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    sleep 0.025

    # 显示菜单
    echo -e "目前支持: Magisk, Alpha, KitsuneMask, Canary, APatch, APatchNext, KernelSU, KernelSUNext"
    sleep 0.025
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"

    echo -e "[${GREEN}a${NC}] ${YELLOW}显示设备信息${NC}"
    echo -e ""
    echo -e "[${GREEN}1${NC}] ${YELLOW}开关闭开发者功能${NC}"
    echo -e ""
    echo -e "[${GREEN}2${NC}] ${YELLOW}安装隐藏必要的模块${NC}"
    echo -e ""
    echo -e "[${GREEN}3${NC}] ${YELLOW}配置隐藏应用列表(可过Luna)${NC}"
    echo -e ""
    echo -e "[${GREEN}4${NC}] ${YELLOW}安装检测14个软件${NC}"
    echo -e ""
    echo -e "[${GREEN}5${NC}] ${YELLOW}过环境功能${NC}"


    # 获取用户输入
    while true; do
        echo -e "${GREEN}请输入数值：${NC}"
    sleep 0.025
        read input
        if [ -z "$input" ]; then
            warn "输入不能为空，请重新输入！"
    sleep 0.025
        else
            break
        fi
    done

    # 处理用户输入
    case $input in
        1)
            clear
            settings put global development_settings_enabled 1
            settings put global adb_enabled 1
            settings put secure install_non_market_apps 1
            settings put global adb_wifi_enabled 1
            log "开发者选项、USB调试、USB安装、USB调试（安全模式）已开启"
            show_options_menu
            ;;
        2)
            clear
            #Install_Modules_Menu
            Module_Install
            show_jzmk_menu
            ;;
        3)
            clear
                configure_hidden_apps
            ;;
        4)
            clear
            if download_file "$APK_URL" "$APK_ZIP"; then
                install_module "$APK_ZIP"
            fi
            show_options_menu
            ;;
        5)
            clear
            hide_menu
            ;;
        
        a)
            show_device_info
            ;;
        D)
            if [ -f /data/adb/shamiko/Debugging.db ]; then
        rm -f /data/adb/shamiko/Debugging.db
        echo "关闭成功"
    else
        touch /data/HRPS/Debugging.db
        echo "开启成功"
            fi
            ;;
        *)
            warn "无效输入"
            show_options_menu
            ;;
    esac



}


# 主函数
main_a() {
    # 显示标题
    clear
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"

# START 的数码管风格ASCII艺术字
echo -e "${WHITE}"
cat << 'EOF'
  _____________     ________________
 / ______   __//\  | _____ \____ ___\
| (___   | | //  \ | | __) )   | |
 \___ \  | |//    \| |  ___/   | |
 ____) | | |/ //\  \ |\ \      | |
|_____/  |_|   ￣   \| \_\     |_|
    
EOF
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo -e "你正在使用酷安@抱紧我的玄黑黑鲨4S的AHide脚本"
    echo -e "二改请标注原作者（@WYing-CCC (无影.)）"
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo -e "${TRUE_ORANGE}当前版本：AHideV3开源${NC}"
    echo -e ""
    echo -e "${RED}使用脚本前你需要保证自己有一定的救砖能力"
    echo -e "您必须要了解Fastboot刷机，刷写boot,dtbo,super分区行为"
    echo -e "您必须了解Recovery删模块"
    echo -e "离开本脚本后用户的任何行为导致变砖本作者概不负责！${NC}"
    echo -e "本脚本在二改时，禁止添加恶意代码，如果发现并提交到了Github上，本人会提交${TRUE_ORANGE}DMCA删除请求${NC}"
    echo -e ""
    echo -e "${YELLOW}更新日志${YC}"
    echo -e "${YELLOW}1.优化了部分代码${YC}"
    echo -e "${YELLOW}2.修复了网址问题${YC}"
    echo -e "${GREEN}—————————————————————————————————————————————————————${NC}"
    echo -e "${BLUE}请输入[1/2]选择[执行/退出]隐藏脚本${NC}"
    # 获取用户输入
    while true; do
        echo -e "${GREEN}请输入数值：${NC}"
    sleep 0.025
        read input
        if [ -z "$input" ]; then
            warn "输入不能为空，请重新输入！"
    sleep 0.025
        else
            break
        fi
    done

    # 处理用户输入
    case $input in
        1)
            clear
            main_b
            ;;
        2)
            exit 0 
            ;;
    esac




}
main_a
# 调用主函数

