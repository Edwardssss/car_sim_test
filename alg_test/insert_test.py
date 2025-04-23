"""
@File    :   insert_test.py
@Time    :   2025/04/22 14:02:52
@Author  :   Edwardssss
@Version :   1.0
@Desc    :   None
"""

import numpy as np
from scipy.signal import resample
import matplotlib.pyplot as plt
import tkinter


def generate_multipath_channel(num_paths=3, max_delay=1e-6, snr_db=30):
    """
    生成多径信道冲激响应
    :param num_paths: 多径数量
    :param max_delay: 最大时延（秒）
    :param snr_db: 信噪比（dB）
    :return: (time_axis, h) 时域冲激响应
    """
    # 随机生成时延和幅度
    delays = np.sort(np.random.uniform(0, max_delay, num_paths))
    amplitudes = np.random.rayleigh(scale=1.0, size=num_paths)
    phases = np.random.uniform(0, 2 * np.pi, num_paths)

    # 构造冲激响应
    t_max = max_delay * 1.2  # 时间轴范围
    fs = 100e6  # 采样率 100 MHz
    num_samples = int(t_max * fs)
    time_axis = np.linspace(0, t_max, num_samples)
    h = np.zeros(num_samples, dtype=complex)

    for delay, amp, phase in zip(delays, amplitudes, phases):
        idx = int(delay * fs)
        if idx < num_samples:
            h[idx] += amp * np.exp(1j * phase)

    # 添加噪声
    noise_power = 10 ** (-snr_db / 10) * np.mean(np.abs(h) ** 2)
    h += np.sqrt(noise_power / 2) * (
        np.random.randn(num_samples) + 1j * np.random.randn(num_samples)
    )

    return time_axis, h


# 生成并可视化信道冲激响应
if __name__ == "__main__":
    print("Hello 你好")
    print(tkinter.TkVersion)
    t, h = generate_multipath_channel(num_paths=5, max_delay=1e-6, snr_db=30)
    plt.stem(t, np.abs(h))
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.title("Multipath Channel Impulse Response")
    plt.show()
    NFFT = 1024
    fs = 12.8 * 2 * pow(10, 6)
    print(fs)
