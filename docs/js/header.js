const progress=document.getElementById("scroll_progress");

document.addEventListener("DOMContentLoaded", function(){
  const bodies=document.getElementsByClassName("link-card");
  const texts=document.getElementsByClassName("link_text");
  for(let i=0;i<texts.length;i++){
    texts.item(i).innerText=bodies.item(i).href;
  }
  const titles=document.getElementsByClassName("link-card-title");
  for(let i=0;i<titles.length;i++){
    titles.item(i).innerText=titles.item(i).dataset.title;
  }
  const descs=document.getElementsByClassName("link-card-description");
  for(let i=0;i<descs.length;i++){
    descs.item(i).innerText=descs.item(i).dataset.desc;
  }
  
  const available_progress=location.href.includes("works")&&!this.location.href.endsWith("works/");
  const available_height=parseFloat(document.documentElement.scrollHeight)>parseFloat(document.documentElement.clientHeight);
  
  if(available_progress&&available_height){
    progress.style.visibility="visible";
  }else{
    progress.style.visibility="hidden";
  }
});

window.onscroll=function(){
  const ratio=parseFloat(document.documentElement.scrollTop)/(parseFloat(document.documentElement.scrollHeight)-parseFloat(document.documentElement.clientHeight));
  progress.value=ratio;
}