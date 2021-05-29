<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let posLinks = [];
    onMount(async () => {
        let lang = window.location.pathname.split("/")[2];
        fetch("/api/posLinks/" + lang).then((r) => {return r.json()}).then((d) => {posLinks = _.filter(d.POSLinks, (l) => l != "") })
    })

    function handlePos(cat) {
        let lang = cat.split("_")[0];
        let wordClass = cat.split("_")[1];
        const regexp = /s$/ig;
        wordClass = wordClass.replaceAll(regexp, "");
        fetch(`/api/initUnmatched/${lang}/${wordClass}`, {method: "POST"});
    }

</script>

<div>
    <h2 class="center">{window.location.pathname.split("/")[2]}</h2>
<div class="langInfoContainer flexContainer">
    {#each posLinks as link}
        <button on:click={() => handlePos(link.split("Category:")[1])}>{link.split("Category:")[1].replaceAll("_", " ")}</button>
    {/each}
</div>
</div>

<style></style>