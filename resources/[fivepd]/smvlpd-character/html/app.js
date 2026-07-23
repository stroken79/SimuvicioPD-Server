console.log("APP.JS VERSION 16-07-2026");
const panel=document.querySelector('#panel'), selection=document.querySelector('#selection'), creator=document.querySelector('#creator');
const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)}).then(r=>r.json());
let gender = 'male';
let face = 0;
let hair = 0;
let hairColor = 0;
let beard = 0;
let glasses = -1;

function updateText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}

const error=(text='')=>document.querySelector('#error').textContent=text;
function showCreator() {

    selection.classList.add('hidden');

    creator.classList.remove('hidden');

    error('');

    document.querySelector('#firstName').focus();

}
window.addEventListener('message',e=>{const d=e.data;if(d.action==='open'){panel.classList.remove('hidden');selection.classList.remove('hidden');creator.classList.add('hidden');const list=document.querySelector('#characters');list.innerHTML='';d.characters.forEach(c=>{const b=document.createElement('button'),small=document.createElement('small');b.className='character';b.append(document.createTextNode(`${c.first_name} ${c.last_name}`));small.textContent=`Agente · Slot ${c.slot}`;b.append(small);b.onclick=()=>post('select',{id:c.id});list.append(b)});document.querySelector('#newCharacter').classList.toggle('hidden',d.characters.length>=d.maxCharacters)}if(d.action==='creator')showCreator();
if(d.action==='error')error(d.message||'Error');if(d.action==='close')panel.classList.add('hidden');});
document.querySelector('#newCharacter').onclick=()=>post('startCreate');
document.querySelectorAll('[data-gender]').forEach(b=>b.onclick=()=>{gender=b.dataset.gender;document.querySelectorAll('[data-gender]').forEach(x=>x.classList.toggle('selected',x===b));post('gender',{gender})});



function sendAppearance(type, value) {
    post("appearance", {
        type: type,
        value: value
    });
}

document.getElementById("facePrev").onclick = () => {
    if (face > 0) face--;
    updateText("face", face);
    sendAppearance("face", face);
};

document.getElementById("faceNext").onclick = () => {
    face++;
    updateText("face", face);
    sendAppearance("face", face);
};

document.getElementById("hairPrev").onclick = () => {
    if (hair > 0) hair--;
    updateText("hair", hair);
    sendAppearance("hair", hair);
};

document.getElementById("hairNext").onclick = () => {
    hair++;
    updateText("hair", hair);
    sendAppearance("hair", hair);
};

document.getElementById("hairColorPrev").onclick = () => {
    if (hairColor > 0) hairColor--;
    updateText("hairColor", hairColor);
    sendAppearance("hairColor", hairColor);
};

document.getElementById("hairColorNext").onclick = () => {
    hairColor++;
    updateText("hairColor", hairColor);
    sendAppearance("hairColor", hairColor);
};

document.getElementById("beardPrev").onclick = () => {
    if (beard > 0) beard--;
    updateText("beard", beard);
    sendAppearance("beard", beard);
};

document.getElementById("beardNext").onclick = () => {
    beard++;
    updateText("beard", beard);
    sendAppearance("beard", beard);
};

document.getElementById("glassesPrev").onclick = () => {
    if (glasses > -1) glasses--;
    updateText("glasses", glasses == -1 ? "Ninguna" : glasses);
    sendAppearance("glasses", glasses);
};

document.getElementById("glassesNext").onclick = () => {
    glasses++;
    updateText("glasses", glasses);
    sendAppearance("glasses", glasses);
};document.querySelector('#confirm').onclick=()=>post('create',{firstName:document.querySelector('#firstName').value,lastName:document.querySelector('#lastName').value,gender}).then(r=>{if(!r.ok)error(r.error)});
