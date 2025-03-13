import matplotlib.pyplot as plt

# 図と軸を作成
fig, ax = plt.subplots()

# テキストを描画
text = ax.text(0.5, 0.5, 'Please wait...', fontsize=50, fontname='Arial', color='white',
               ha='center', va='center', bbox=dict(facecolor='red', alpha=0.5))

# 軸の設定
ax.axis('tight')
ax.axis('off')
ax.set_xlim([0, 1])
ax.set_ylim([0, 1])

# 図の表示
plt.show()
