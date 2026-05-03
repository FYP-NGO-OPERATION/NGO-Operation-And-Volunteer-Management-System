import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

OUT_DIR = "diagrams"
os.makedirs(OUT_DIR, exist_ok=True)

def create_canvas(figsize=(10, 6)):
    fig, ax = plt.subplots(figsize=figsize)
    ax.axis('off')
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    return fig, ax

def draw_box(ax, x, y, w, h, text, color='#E8F0FE'):
    rect = patches.Rectangle((x, y), w, h, linewidth=1.5, edgecolor='#1A73E8', facecolor=color, alpha=0.9, zorder=2)
    ax.add_patch(rect)
    ax.text(x + w/2, y + h/2, text, horizontalalignment='center', verticalalignment='center', 
            fontsize=11, fontweight='bold', family='sans-serif', zorder=3)

def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(facecolor='#5F6368', shrink=0.05, width=2, headwidth=8), zorder=1)

# 1. Ch1: Operational Workflow
fig, ax = create_canvas()
draw_box(ax, 1, 8, 8, 1, "Status Quo: Manual NGO Operations")
draw_box(ax, 1, 5, 3, 2, "WhatsApp Groups\n(Lost Data)")
draw_box(ax, 6, 5, 3, 2, "Paper Ledgers\n(No Transparency)")
draw_arrow(ax, 2.5, 8, 2.5, 7)
draw_arrow(ax, 7.5, 8, 7.5, 7)
draw_box(ax, 1, 1, 8, 1.5, "HRAS System: Unified Digital Pipeline\n(Real-time, Secure, Immutable)", color='#CEEAD6')
draw_arrow(ax, 2.5, 5, 2.5, 2.5)
draw_arrow(ax, 7.5, 5, 7.5, 2.5)
fig.savefig(f"{OUT_DIR}/ch1_workflow.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 2. Ch2: Literature Arch Evolution
fig, ax = create_canvas()
draw_box(ax, 1, 7, 8, 1.5, "Phase 1: Desktop CRM\n(Expensive, Immobile)")
draw_arrow(ax, 5, 7, 5, 5.5)
draw_box(ax, 1, 4, 8, 1.5, "Phase 2: Hybrid Web Wrappers\n(Poor UI Performance)")
draw_arrow(ax, 5, 4, 5, 2.5)
draw_box(ax, 1, 1, 8, 1.5, "Phase 3: Native Flutter Compilation\n(60fps, Single Codebase, Cross-Platform)", color='#CEEAD6')
fig.savefig(f"{OUT_DIR}/ch2_arch_evolution.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 3. Ch3: Agile SDLC Cycle
fig, ax = create_canvas()
draw_box(ax, 4, 8, 2, 1.5, "1. Plan & Analyze\n(Requirements)")
draw_box(ax, 7, 5, 2, 1.5, "2. Design\n(Architecture)")
draw_box(ax, 4, 2, 2, 1.5, "3. Develop\n(Coding)")
draw_box(ax, 1, 5, 2, 1.5, "4. Test & UAT\n(Validation)")
draw_arrow(ax, 6, 8.75, 8, 6.5)
draw_arrow(ax, 8, 5, 6, 2.75)
draw_arrow(ax, 4, 2.75, 2, 5)
draw_arrow(ax, 2, 6.5, 4, 8.75)
ax.text(5, 5.75, "Agile Iterative\nFeedback Loop", ha='center', va='center', fontweight='bold', fontsize=12)
fig.savefig(f"{OUT_DIR}/ch3_agile_sdlc.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 4. Ch5: ERD Database Concept
fig, ax = create_canvas()
draw_box(ax, 1, 6, 2.5, 3, "USERS\n\n- uid (PK)\n- name\n- role\n- skills[]")
draw_box(ax, 7, 6, 2.5, 3, "CAMPAIGNS\n\n- campId (PK)\n- title\n- status\n- tags[]")
draw_box(ax, 4, 1, 2.5, 3, "DONATIONS\n\n- donId (PK)\n- amount\n- receipt\n- timestamp")
draw_arrow(ax, 3.5, 7.5, 7, 7.5)
ax.text(5.25, 7.8, "Registers For (1:N)", ha='center')
draw_arrow(ax, 2.25, 6, 4.5, 4)
ax.text(3, 4.8, "Makes (1:N)", ha='center')
fig.savefig(f"{OUT_DIR}/ch5_erd_concept.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 5. Ch5: Component Architecture
fig, ax = create_canvas()
draw_box(ax, 0.5, 7, 3, 2, "Mobile UI (Flutter)\n[Volunteer Node]")
draw_box(ax, 6.5, 7, 3, 2, "Web Dashboard\n[Admin Node]")
draw_box(ax, 3.5, 4, 3, 2, "Firebase BaaS\n(Cloud Backend)")
draw_arrow(ax, 2, 7, 4, 6)
draw_arrow(ax, 8, 7, 6, 6)
draw_box(ax, 1, 1, 3.5, 1.5, "Firestore NoSQL\n(Real-time Data)")
draw_box(ax, 5.5, 1, 3.5, 1.5, "Firebase Auth\n(Encrypted Tokens)")
draw_arrow(ax, 4.5, 4, 2.75, 2.5)
draw_arrow(ax, 5.5, 4, 7.25, 2.5)
fig.savefig(f"{OUT_DIR}/ch5_component_arch.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 6. Ch6: Smart Matching Algorithm
fig, ax = create_canvas()
draw_box(ax, 2.5, 8, 5, 1, "Initialize Match Engine")
draw_arrow(ax, 5, 8, 5, 7)
draw_box(ax, 0.5, 5, 4, 2, "Fetch User Skills Array\nO(1)")
draw_box(ax, 5.5, 5, 4, 2, "Fetch Active Campaigns\nO(N)")
draw_arrow(ax, 5, 7, 2.5, 7)
draw_arrow(ax, 5, 7, 7.5, 7)
draw_arrow(ax, 2.5, 5, 5, 4)
draw_arrow(ax, 7.5, 5, 5, 4)
draw_box(ax, 2.5, 2, 5, 2, "Calculate Relevance Weight\n& Sort O(N log N)")
draw_arrow(ax, 5, 2, 5, 1)
draw_box(ax, 2.5, 0, 5, 1, "Render Sorted UI Feed", color='#CEEAD6')
fig.savefig(f"{OUT_DIR}/ch6_smart_matching.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 7. Ch7: QA Flow
fig, ax = create_canvas()
draw_box(ax, 1, 7, 8, 1.5, "Phase 1: Automated Unit Testing\n(Validating Regex, Logic & Models)")
draw_arrow(ax, 5, 7, 5, 5.5)
draw_box(ax, 1, 4, 8, 1.5, "Phase 2: Integration & API Testing\n(Validating Network & Database Sync)")
draw_arrow(ax, 5, 4, 5, 2.5)
draw_box(ax, 1, 1, 8, 1.5, "Phase 3: User Acceptance Testing (UAT)\n(Validating UX with Live NGO Volunteers)", color='#CEEAD6')
fig.savefig(f"{OUT_DIR}/ch7_qa_flow.png", bbox_inches='tight', dpi=300)
plt.close(fig)

# 8. Ch8: Strategic Roadmap
fig, ax = create_canvas()
draw_box(ax, 1, 8, 8, 1, "Immediate: Final Deployment & Handover")
draw_arrow(ax, 5, 8, 5, 7)
draw_box(ax, 1, 5.5, 8, 1.5, "Short-Term: Localization Engine\n(Urdu Translation Support)")
draw_arrow(ax, 5, 5.5, 5, 4.5)
draw_box(ax, 1, 3, 8, 1.5, "Mid-Term: Geospatial Integration\n(GPS Event Tracking)")
draw_arrow(ax, 5, 3, 5, 2)
draw_box(ax, 1, 0.5, 8, 1.5, "Long-Term: Predictive Machine Learning\n(AI Donation Analytics)", color='#FAD2CF')
fig.savefig(f"{OUT_DIR}/ch8_strategic_roadmap.png", bbox_inches='tight', dpi=300)
plt.close(fig)

print("Successfully generated 8 high-quality academic diagrams via matplotlib.")
