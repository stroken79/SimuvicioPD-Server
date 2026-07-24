const IMAGES = {
    passive: 'breathalyzer_pas.png',
    evidential: 'breathalyzer_evi.png',
};

const TEST_TYPES = {
    passive: { mode: 'Passive', passSub: '- Passive -', failSub: '- Passive -' },
    evidential: { mode: 'Evidential', passSub: '- Evidential -', failSub: '- Evidential -' },
};

const SCREENS = {
    ready: { main: 'READY', sub: '', footer: '', className: 'state-ready' },
    wait: { main: 'Wait', sub: 'Analyzing', footer: '', className: 'state-wait' },
    awaiting: { main: 'Wait', sub: 'Subject', footer: '', className: 'state-wait' },
    pass: { main: 'Pass', footer: 'Confirm', className: 'state-pass' },
    fail: { main: 'Fail', footer: 'Confirm', className: 'state-fail' },
    error: { main: 'No Subject', sub: 'Move closer', footer: '', className: 'state-error' },
};

const ui = {
    root: document.getElementById('breathalyzer'),
    deviceImage: document.getElementById('device-image'),
    lcdScreen: document.getElementById('lcd-screen'),
    lcdMode: document.getElementById('lcd-mode'),
    lcdMain: document.getElementById('lcd-main'),
    lcdSub: document.getElementById('lcd-sub'),
    lcdFooter: document.getElementById('lcd-footer'),
    lcdTime: document.getElementById('lcd-time'),
    lcdDate: document.getElementById('lcd-date'),
    beep: document.getElementById('beep'),
    testing: document.getElementById('testing'),
    btnLeft: document.getElementById('btn-left'),
    btnOk: document.getElementById('btn-ok'),
    testeeRoot: document.getElementById('testee-overlay'),
    testeeDeviceImage: document.getElementById('testee-device-image'),
    testeeLcdScreen: document.getElementById('testee-lcd-screen'),
    testeeLcdBody: document.getElementById('testee-lcd-body'),
    testeeLcdMode: document.getElementById('testee-lcd-mode'),
    testeeLcdMain: document.getElementById('testee-lcd-main'),
    testeeLcdSub: document.getElementById('testee-lcd-sub'),
    testeeLcdFooter: document.getElementById('testee-lcd-footer'),
    testeeLcdTime: document.getElementById('testee-lcd-time'),
    testeeLcdDate: document.getElementById('testee-lcd-date'),
    testeePassiveInput: document.getElementById('testee-passive-input'),
    testeeEvidentialInput: document.getElementById('testee-evidential-input'),
    testeeLimitHint: document.getElementById('testee-limit-hint'),
    testeeInputUnitLabel: document.getElementById('testee-input-unit-label'),
    inputBac: document.getElementById('input-bac'),
    inputPass: document.getElementById('input-pass'),
    inputFail: document.getElementById('input-fail'),
    inputSubmit: document.getElementById('input-submit'),
};

const config = {
    defaultTestType: 'passive',
    errorDisplayDuration: 2500,
    legalLimit: 0.25,
    maxBacInput: 9.999,
    decimalPlaces: 3,
    unitLabel: 'mcg',
};

const state = {
    visible: false,
    testType: 'passive',
    testeeType: 'passive',
    currentState: 'ready',
    testInProgress: false,
    testingPlaying: false,
    errorTimer: null,
};

const testerLcd = {
    image: ui.deviceImage,
    screen: ui.lcdScreen,
    mode: ui.lcdMode,
    main: ui.lcdMain,
    sub: ui.lcdSub,
    footer: ui.lcdFooter,
};

const testeeLcd = {
    image: ui.testeeDeviceImage,
    screen: ui.testeeLcdScreen,
    mode: ui.testeeLcdMode,
    main: ui.testeeLcdMain,
    sub: ui.testeeLcdSub,
    footer: ui.testeeLcdFooter,
};

function nui(event, payload = {}) {
    return fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload),
    });
}

function pad(value) {
    return String(value).padStart(2, '0');
}

function applyConfig(nextConfig) {
    if (!nextConfig) return;

    Object.assign(config, nextConfig);

    if (config.defaultTestType !== 'passive' && config.defaultTestType !== 'evidential') {
        config.defaultTestType = 'passive';
    }

    ui.inputBac.max = config.maxBacInput;
    ui.inputBac.step = 10 ** -config.decimalPlaces;
    ui.testeeInputUnitLabel.textContent = `Reading (${config.unitLabel})`;
}

function updateClocks() {
    const now = new Date();
    const time = `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    const date = `${pad(now.getDate())}.${pad(now.getMonth() + 1)}.${now.getFullYear()}`;

    ui.lcdTime.textContent = time;
    ui.lcdDate.textContent = date;
    ui.testeeLcdTime.textContent = time;
    ui.testeeLcdDate.textContent = date;
}

function requestSound(sound, options = {}) {
    nui('playSound', { sound, stop: options.stop || false }).catch(() => {});
}

function stopTestingSound() {
    ui.testing.pause();
    ui.testing.currentTime = 0;
    state.testingPlaying = false;
}

function playProximitySound(sound, volume, stop) {
    if (stop) {
        stopTestingSound();
        return;
    }

    const element = sound === 'testing' ? ui.testing : ui.beep;
    element.volume = Math.max(0, Math.min(1, volume ?? 1));
    element.currentTime = 0;

    if (sound === 'testing') {
        if (state.testingPlaying) return;
        state.testingPlaying = true;
        element.play().catch(() => {
            state.testingPlaying = false;
        });
        element.onended = () => {
            state.testingPlaying = false;
        };
        return;
    }

    element.play().catch(() => {});
}

function applyLcd(target, screenKey, type, options = {}) {
    const screen = SCREENS[screenKey] || SCREENS.ready;
    const typeConfig = TEST_TYPES[type] || TEST_TYPES.passive;

    target.image.src = IMAGES[type];
    target.mode.textContent = typeConfig.mode;
    target.footer.textContent = screen.footer || '';

    if (screenKey === 'pass' || screenKey === 'fail') {
        if (type === 'evidential' && options.displayValue) {
            target.main.textContent = options.displayValue;
            target.sub.textContent = screenKey === 'pass' ? typeConfig.passSub : typeConfig.failSub;
        } else {
            target.main.textContent = screen.main;
            target.sub.textContent = screenKey === 'pass' ? typeConfig.passSub : typeConfig.failSub;
        }
    } else {
        target.main.textContent = options.main || screen.main;
        target.sub.textContent = options.sub ?? screen.sub ?? '';
    }

    target.screen.className = 'lcd-screen';
    if (screen.className) {
        target.screen.classList.add(screen.className);
    }
}

function applyTesterScreen(screenKey, options = {}) {
    state.currentState = screenKey;
    applyLcd(testerLcd, screenKey, state.testType, options);
}

function applyTesteeScreen(screenKey, type, options = {}) {
    applyLcd(testeeLcd, screenKey, type, options);
}

function hideTesteeInput() {
    ui.testeeLcdBody.classList.remove('show-input');
    ui.testeePassiveInput.classList.add('hidden');
    ui.testeeEvidentialInput.classList.add('hidden');
}

function showTesteeInput(type, evidential = {}) {
    hideTesteeInput();
    ui.testeeLcdBody.classList.add('show-input');

    if (type === 'passive') {
        ui.testeePassiveInput.classList.remove('hidden');
        return;
    }

    const legalLimit = evidential.legalLimit ?? config.legalLimit;
    const unitLabel = evidential.unitLabel ?? config.unitLabel;
    const decimalPlaces = evidential.decimalPlaces ?? config.decimalPlaces;
    const maxBacInput = evidential.maxBacInput ?? config.maxBacInput;

    ui.testeeEvidentialInput.classList.remove('hidden');
    ui.testeeInputUnitLabel.textContent = `Reading (${unitLabel})`;
    ui.testeeLimitHint.textContent = `Limit: ${Number(legalLimit).toFixed(decimalPlaces)} ${unitLabel}`;
    ui.inputBac.max = maxBacInput;
    ui.inputBac.step = 10 ** -decimalPlaces;
    ui.inputBac.value = '';
}

function setTesteeVisible(show) {
    ui.testeeRoot.classList.toggle('hidden', !show);
    ui.testeeRoot.setAttribute('aria-hidden', show ? 'false' : 'true');

    if (!show) {
        hideTesteeInput();
    }
}

function clearErrorTimer() {
    if (!state.errorTimer) return;
    clearTimeout(state.errorTimer);
    state.errorTimer = null;
}

function resetTester() {
    clearErrorTimer();
    stopTestingSound();
    state.testInProgress = false;
    applyTesterScreen('ready');
}

function setTesterVisible(show) {
    state.visible = show;
    ui.root.classList.toggle('hidden', !show);
    ui.root.setAttribute('aria-hidden', show ? 'false' : 'true');

    if (show) {
        state.testType = config.defaultTestType;
        resetTester();
        requestSound('beep');
        return;
    }

    clearErrorTimer();
    stopTestingSound();
    state.testInProgress = false;
}

function toggleTestType() {
    if (state.currentState === 'wait' || state.currentState === 'awaiting' || state.testInProgress) {
        return;
    }

    state.testType = state.testType === 'passive' ? 'evidential' : 'passive';
    applyTesterScreen(state.currentState);
}

function showTesterError(errorCode) {
    clearErrorTimer();
    state.testInProgress = false;
    stopTestingSound();

    const busy = errorCode === 'busy';
    applyTesterScreen('error', {
        main: busy ? 'Subject Busy' : 'No Subject',
        sub: busy ? 'Try again' : 'Move closer',
    });
    requestSound('beep');

    state.errorTimer = setTimeout(() => {
        state.errorTimer = null;
        if (!state.testInProgress) {
            applyTesterScreen('ready');
        }
    }, config.errorDisplayDuration);
}

async function startTest() {
    try {
        const response = await nui('startTest', { testType: state.testType });
        const result = await response.json();
        if (!result.ok) {
            showTesterError(result.error || 'no_player');
        }
    } catch (_) {
        showTesterError('no_player');
    }
}

function submitPassiveResult(outcome) {
    hideTesteeInput();
    nui('submitTesteeResult', { outcome }).catch(() => {});
}

function submitEvidentialResult() {
    const value = parseFloat(ui.inputBac.value);
    if (Number.isNaN(value) || value < 0) {
        ui.inputBac.focus();
        return;
    }

    hideTesteeInput();
    nui('submitTesteeResult', { value }).catch(() => {});
}

async function confirmTest() {
    await nui('confirmTest').catch(() => {});
    resetTester();
}

function onTesterButton(button) {
    requestSound('beep');

    if (button === 'left') {
        toggleTestType();
        return;
    }

    if (button === 'ok') {
        if (state.currentState === 'ready') {
            startTest();
        } else if (state.currentState === 'pass' || state.currentState === 'fail') {
            confirmTest();
        }
    }
}

const handlers = {
    setConfig: applyConfig,
    setVisible: (data) => setTesterVisible(!!data.visible),
    testerAwaitingSubject: (data) => {
        state.testInProgress = true;
        state.testType = data.testType || state.testType;
        applyTesterScreen('awaiting');
    },
    analyzeWait: (data) => {
        if (data.role === 'tester') {
            state.testType = data.testType || state.testType;
            applyTesterScreen('wait');
            return;
        }

        if (data.role === 'testee') {
            state.testeeType = data.testType || state.testeeType;
            hideTesteeInput();
            applyTesteeScreen('wait', state.testeeType);
        }
    },
    testerResult: (data) => {
        stopTestingSound();
        applyTesterScreen(data.result, { displayValue: data.displayValue });
    },
    testerError: (data) => showTesterError(data.error),
    testeeStart: (data) => {
        state.testeeType = data.testType || 'passive';
        setTesteeVisible(true);
    },
    testeePrompt: (data) => {
        state.testeeType = data.testType || state.testeeType;
        applyTesteeScreen('ready', state.testeeType);
        showTesteeInput(state.testeeType, data.evidential);
    },
    testeeResult: (data) => {
        stopTestingSound();
        hideTesteeInput();
        applyTesteeScreen(data.result, data.testType, { displayValue: data.displayValue });
    },
    playProximitySound: (data) => playProximitySound(data.sound, data.volume, data.stop),
    testEnded: () => {
        stopTestingSound();
        state.testInProgress = false;
        setTesteeVisible(false);
        if (state.visible && state.currentState !== 'ready') {
            resetTester();
        }
    },
};

ui.btnLeft.addEventListener('click', () => onTesterButton('left'));
ui.btnOk.addEventListener('click', () => onTesterButton('ok'));
ui.inputPass.addEventListener('click', () => submitPassiveResult('pass'));
ui.inputFail.addEventListener('click', () => submitPassiveResult('fail'));
ui.inputSubmit.addEventListener('click', submitEvidentialResult);

ui.inputBac.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        submitEvidentialResult();
    }
});

document.addEventListener('keydown', (event) => {
    if (!state.visible) return;

    if (event.key === 'Escape' || event.key === 'Backspace') {
        nui('close').catch(() => {});
    }
});

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (!action) return;

    const handler = handlers[action];
    if (handler) {
        handler(data || {});
    }
});

updateClocks();
setInterval(updateClocks, 1000);
