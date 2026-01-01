
        // --- BADGE SYSTEM LOGIC ---
        window.renderBadges = async () => {
            const container = $('#badges-grid');
            container.empty();

            if (!userProfile || userProfile.role !== 'student') {
                container.html(`<div class="col-span-full text-center py-4 text-slate-400 text-xs italic">Badges are only for students.</div>`);
                return;
            }

            // Fetch latest arcade progress if not cached
            let arcade = window.allArcadeProgress ? window.allArcadeProgress.find(p => p.user_id === currentUser.id) : null;
            if (!arcade && client) {
                const { data } = await client.from('user_arcade_progress').select('*').eq('user_id', currentUser.id).maybeSingle();
                arcade = data;
            }

            // Fetch submission stats
            const mySubs = window.allSubmissions ? window.allSubmissions.filter(s => s.student_id === currentUser.id && s.status === 'graded') : [];
            const avgGrade = mySubs.length ? (mySubs.reduce((a, b) => a + b.grade, 0) / mySubs.length) : 0;

            const badges = [
                {
                    id: 'html_master',
                    title: 'HTML Master',
                    desc: 'Reach "Hard" level in HTML Arcade',
                    icon: 'code-2',
                    color: 'orange',
                    unlocked: arcade?.html_level === 'hard'
                },
                {
                    id: 'css_pro',
                    title: 'CSS Pro',
                    desc: 'Reach "Hard" level in CSS Arcade',
                    icon: 'palette',
                    color: 'cyan',
                    unlocked: arcade?.css_level === 'hard'
                },
                {
                    id: 'js_wizard',
                    title: 'JS Wizard',
                    desc: 'Reach "Hard" level in JS Arcade',
                    icon: 'zap',
                    color: 'yellow',
                    unlocked: arcade?.js_level === 'hard'
                },
                {
                    id: 'bug_hunter',
                    title: 'Bug Hunter',
                    desc: 'Score > 500 in Syntax Balloons',
                    icon: 'bug',
                    color: 'rose',
                    // Mock check: If they played Balloons enough to have a level > 1
                    unlocked: (arcade?.syntax_balloons_score > 500) || false 
                },
                {
                    id: 'speed_coder',
                    title: 'Speed Coder',
                    desc: 'Complete 5 Speed Challenges',
                    icon: 'timer',
                    color: 'purple',
                    unlocked: (arcade?.css_level === 'moderate' || arcade?.css_level === 'hard') // Mock logic
                },
                {
                    id: 'task_master',
                    title: 'Task Master',
                    desc: 'Complete 10+ Assignments',
                    icon: 'clipboard-check',
                    color: 'emerald',
                    unlocked: mySubs.length >= 10
                },
                {
                    id: 'top_performer',
                    title: 'Top Performer',
                    desc: 'Maintain 90%+ Average Grade',
                    icon: 'star',
                    color: 'indigo',
                    unlocked: avgGrade >= 90 && mySubs.length >= 3
                },
                {
                    id: 'streak_7',
                    title: '7-Day Streak',
                    desc: 'Login for 7 consecutive days',
                    icon: 'flame',
                    color: 'amber',
                    unlocked: false // Placeholder for future logic
                }
            ];

            badges.forEach(b => {
                const opacity = b.unlocked ? 'opacity-100' : 'opacity-40 grayscale';
                const bg = b.unlocked ? `bg-${b.color}-50 dark:bg-${b.color}-900/20` : 'bg-slate-100 dark:bg-slate-800';
                const border = b.unlocked ? `border-${b.color}-200 dark:border-${b.color}-800/50` : 'border-slate-200 dark:border-slate-700';
                const text = b.unlocked ? `text-${b.color}-600 dark:text-${b.color}-400` : 'text-slate-400';
                const lockIcon = b.unlocked ? '' : `<div class="absolute top-2 right-2 text-slate-400"><i data-lucide="lock" class="w-3 h-3"></i></div>`;

                container.append(`
                    <div class="relative p-4 rounded-2xl border ${border} ${bg} ${opacity} transition-all flex flex-col items-center text-center group hover:scale-[1.02]">
                        ${lockIcon}
                        <div class="w-10 h-10 rounded-full bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 flex items-center justify-center mb-3 shadow-sm ${text}">
                            <i data-lucide="${b.icon}" class="w-5 h-5"></i>
                        </div>
                        <h5 class="font-black text-[10px] uppercase tracking-wider text-slate-900 dark:text-white mb-1">${b.title}</h5>
                        <p class="text-[8px] font-bold text-slate-400 leading-tight">${b.desc}</p>
                    </div>
                `);
            });
            lucide.createIcons();
        };
