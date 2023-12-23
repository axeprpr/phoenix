<!--
 * @Description: 
 * @Date: 2023-12-23 11:38:38
 * @LastEditTime: 2023-12-23 11:38:43
 * @FilePath: \phoenixd:\archive\dev\github\phoenix\README.md
-->
# ph性能测试

### 使用
1. ph info
```
[root@host039 ~(keystone_admin)]# ph info
----------------------------------------------------------------------
系统信息
----------------------------------------------------------------------
Hostname        :  host039
System Name     :  CentOS 7.7.1908
System Kernel   :  3.10.0-1062.el7.x86_64
Current Time    :  2023-12-23 01:25
Boot Time       :  2023-12-06 18:17
Manufacturer    :  Supermicro SYS-4028GR-TR2
CPU Model       :  Intel(R) Xeon(R) CPU E5-2687W v3 @ 3.10GHz
CPU Number      :  2
CPU Threads     :  40
CPU Frequency   :  3199.902
CPU VMM Type    :  none
CPU VMX         :  Intel VT-x
Load            :  3.86, 3.73, 3.49
Memory Info     :  Used: 115G Total: 251G
Disk Info       :  sda 2.6T/
----------------------------------------------------------------------
You have mail in /var/spool/mail/root

```
2. ph cpu -s/-m
```
[root@host039 ~(keystone_admin)]# ph cpu -m
----------------------------------------------------------------------
CPU基本信息
----------------------------------------------------------------------
CPU Model       :  Intel(R) Xeon(R) CPU E5-2687W v3 @ 3.10GHz
CPU Number      :  2
CPU Threads     :  40
CPU Frequency   :  3199.902
----------------------------------------------------------------------
开始进行CPU多线程测试..
当前环境线程数：40，使用26个线程进行多线程测试 ..
/
测试结果参考：
----------------------------------------------------------------------
Intel N2840         | 4    Threads   | 3080        | 4080
Intel i5-650        | 4    Threads   | 8200        | 9460
Intel Xeon x5650    | 12   Threads   | 16200       | 22700
Intel i7 4770       | 8    Threads   | 20500       | 21000
Intel i7-6700       | 8    Threads   | 24700       | 22900
Apple M1            | 8    Threads   | 50365       | 45009
Ryzen 5600G         | 12   Threads   | 55507       | 83299
Your CPU            | 26   Threads   | 74663       | 83981       
Intel E5-2699 v4    | 44   Threads   | 107000      | 87000
Intel E5-2699 v4*2  | 88   Threads   | 186000      | 174000
----------------------------------------------------------------------
```
3. ph disk -d /mnt(目录) -s 10m(大小)
如果啥都不填就是当前目录。默认是256MB
```
[root@host039 ~(keystone_admin)]# ph disk -d /mnt -s 1m
----------------------------------------------------------------------
磁盘基本信息：
----------------------------------------------------------------------

NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0  2.6T  0 disk 
├─sda1                    8:1    0  100M  0 part /boot/efi
├─sda2                    8:2    0  400M  0 part /boot
├─sda3                    8:3    0   80G  0 part 
│ └─vg_sys-lv_sys       253:3    0   80G  0 lvm  /
├─sda4                    8:4    0    4G  0 part [SWAP]
├─sda5                    8:5    0    1M  0 part 
├─sda6                    8:6    0   32G  0 part 
│ └─vg_db-lv_db         253:2    0   32G  0 lvm  /var/lib/mysql
├─sda7                    8:7    0  100G  0 part 
│ └─vg_glance-lv_glance 253:1    0  100G  0 lvm  /var/lib/glance
└─sda8                    8:8    0  2.4T  0 part 
  └─vg_nova-lv_nova     253:0    0  2.4T  0 lvm  /var/lib/nova

----------------------------------------------------------------------
开始在/mnt进行磁盘性能测试；测试文件大小为1m
-
测试结果参考：

|      | Read(MB/s)|Write(MB/s)|
|------|-----------|-----------|
|  Seq |    262.000|    350.000|
| 512K |    210.000|    524.000|
|   4K |     49.900|     61.700|
|4KQD32|    210.000|    262.000|

----------------------------------------------------------------------
```
4. pg mem -s 1(内存大小)
```
----------------------------------------------------------------------
内存基本信息：
----------------------------------------------------------------------

              total        used        free      shared  buff/cache   available
Mem:           251G        115G        122G        4.1G         13G        130G
Swap:          4.0G          0B        4.0G

----------------------------------------------------------------------
内存设备信息：
----------------------------------------------------------------------

Memory Device 1: Samsung 32GB DDR4 2667MT/s
Memory Device 2: Samsung 32GB DDR4 2667MT/s
Memory Device 3: Samsung 32GB DDR4 2667MT/s
Memory Device 4: Samsung 32GB DDR4 2667MT/s
Memory Device 5: Samsung 32GB DDR4 2667MT/s
Memory Device 6: Samsung 32GB DDR4 2667MT/s
Memory Device 7: Samsung 32GB DDR4 2667MT/s
Memory Device 8: Samsung 32GB DDR4 2667MT/s

----------------------------------------------------------------------
开始进行内存性能测试；测试内存大小为1MB

memtester version 4.6.0 (64-bit)
Copyright (C) 2001-2020 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 1MB (1048576 bytes)
got  1MB (1048576 bytes), trying mlock ...locked.
Loop 1/1:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Done.

----------------------------------------------------------------------
```
5. ph fast
全量测试
```
略
```