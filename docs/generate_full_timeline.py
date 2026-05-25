import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.patches as patches
import pandas as pd
from datetime import datetime, timedelta
import os

# Create directory if it doesn't exist
diagrams_dir = r"E:\Fyp\ngo_volunteer_app\docs\diagrams"
os.makedirs(diagrams_dir, exist_ok=True)

# Define the tasks for the full FYP lifecycle
tasks = [
    {"Task": "Proposal & Requirements (FYP-1)", "Start": "2026-02-01", "End": "2026-04-15", "Phase": "FYP-1"},
    {"Task": "System Architecture Design", "Start": "2026-04-01", "End": "2026-05-15", "Phase": "FYP-1"},
    {"Task": "MVP Development (Auth & Campaign)", "Start": "2026-05-15", "End": "2026-07-30", "Phase": "FYP-2"},
    {"Task": "Backend Integration (Firebase)", "Start": "2026-06-15", "End": "2026-08-30", "Phase": "FYP-2"},
    {"Task": "AI Analytics Engine Integration", "Start": "2026-08-01", "End": "2026-10-15", "Phase": "FYP-3"},
    {"Task": "System Testing & UAT", "Start": "2026-10-01", "End": "2026-11-15", "Phase": "FYP-3"},
    {"Task": "Final Documentation & Defense", "Start": "2026-11-01", "End": "2026-12-15", "Phase": "FYP-3"}
]

df = pd.DataFrame(tasks)
df['Start'] = pd.to_datetime(df['Start'])
df['End'] = pd.to_datetime(df['End'])

# Create figure and axis
fig, ax = plt.subplots(figsize=(12, 6))

# Colors for phases
colors = {"FYP-1": "#1f77b4", "FYP-2": "#ff7f0e", "FYP-3": "#2ca02c"}

# Plot bars
for i, task in enumerate(df.itertuples()):
    start_date = mdates.date2num(task.Start)
    end_date = mdates.date2num(task.End)
    ax.barh(task.Task, end_date - start_date, left=start_date, color=colors[task.Phase], edgecolor='black', height=0.6, alpha=0.8)
    
    # Add text inside bars
    mid_date = start_date + (end_date - start_date) / 2
    ax.text(mid_date, i, task.Phase, va='center', ha='center', color='white', fontweight='bold')

# Formatting the axes
ax.xaxis.set_major_locator(mdates.MonthLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
plt.xticks(rotation=45)
ax.invert_yaxis() # Highest task at top

# Add grid and labels
ax.grid(True, axis='x', linestyle='--', alpha=0.7)
ax.set_xlabel('Timeline')
ax.set_title('Complete FYP Lifecycle (FYP-1, FYP-2, FYP-3) Gantt Chart', fontsize=14, fontweight='bold')

# Create a legend
legend_elements = [patches.Patch(facecolor=colors['FYP-1'], label='FYP-1 (Research & Design)'),
                   patches.Patch(facecolor=colors['FYP-2'], label='FYP-2 (Core Development)'),
                   patches.Patch(facecolor=colors['FYP-3'], label='FYP-3 (AI, Testing & Final)')]
ax.legend(handles=legend_elements, loc='lower right')

plt.tight_layout()

# Save the figure
out_path = os.path.join(diagrams_dir, "full_fyp_timeline.png")
plt.savefig(out_path, dpi=300)
print(f"Timeline successfully generated at {out_path}")
