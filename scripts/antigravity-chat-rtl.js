/* ==============================================================================
 * PersianAntigravityIDE - فارسی ساز محیط توسعه آنتی گرویتی
 * Project: https://github.com/mehdichamani/PersianAntigravityIDE
 * Target:  Antigravity IDE Workbench DOM (MutationObserver)
 * ============================================================================== */

(function() {
    'use strict';

    // Unicode ranges for Persian, Arabic, and Hebrew characters
    var RTL_REGEX = /[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/;

    function updateRtlElements() {
        var selectors = [
            // Antigravity Agent Side Panel (Chat conversation & responses)
            '.antigravity-agent-side-panel .whitespace-pre-wrap.text-sm',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > p',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ul',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > ol',
            '.antigravity-agent-side-panel .leading-relaxed.select-text li',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h1',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h2',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h3',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > h4',
            '.antigravity-agent-side-panel .leading-relaxed.select-text > blockquote',
            // Central Planning / Artifacts / Walkthrough Editor Pane
            '.jetski-custom-editor-pane p',
            '.jetski-custom-editor-pane ul',
            '.jetski-custom-editor-pane ol',
            '.jetski-custom-editor-pane li',
            '.jetski-custom-editor-pane h1',
            '.jetski-custom-editor-pane h2',
            '.jetski-custom-editor-pane h3',
            '.jetski-custom-editor-pane h4',
            '.jetski-custom-editor-pane h5',
            '.jetski-custom-editor-pane h6',
            '.jetski-custom-editor-pane blockquote'
        ].join(', ');

        var elements = document.querySelectorAll(selectors);

        elements.forEach(function(el) {
            // Strictly exclude code blocks and container elements
            if (el.tagName === 'PRE' || el.tagName === 'CODE' ||
                el.closest('pre') ||
                el.closest('.interactive-result-code-block') ||
                el.closest('.code-block-container')) {
                return;
            }

            // Real-time RTL check on text content
            if (RTL_REGEX.test(el.textContent)) {
                el.classList.add('antigravity-is-rtl');
            } else {
                el.classList.remove('antigravity-is-rtl');
            }
        });
    }

    var updateTimeout = null;
    function scheduleUpdate() {
        if (updateTimeout) return;
        updateTimeout = setTimeout(function() {
            updateTimeout = null;
            updateRtlElements();
        }, 100);
    }

    // Monitor DOM modifications (chat streaming, plan switches, tab changes)
    var observer = new MutationObserver(function() {
        scheduleUpdate();
    });

    observer.observe(document.body, { childList: true, subtree: true });

    // Initial run
    if (document.readyState !== 'loading') {
        scheduleUpdate();
    } else {
        document.addEventListener('DOMContentLoaded', scheduleUpdate);
    }
})();
