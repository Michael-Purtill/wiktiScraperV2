<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    let lang = window.location.pathname.split("/")[2];
    let wordClass =window.location.pathname.split("/")[3];
    let links = [];

    onMount(async () => {
        fetch(`/api/unmatched/${lang}/${wordClass}`).then((r) => {return r.json()}).then((d) => {links = d });
    })

    function openTemplateBuilder(link) {
        window.open(`/testPage/${lang}/${link}`);
    }

    function initUnmatched() {
        const regexp = /s$/ig;
        wordClass = wordClass.replaceAll(regexp, "");
        fetch(`/api/initUnmatched/${lang}/${wordClass}`, {method: "POST"});
    }

</script>

<div>
    <h2 class="center">Unmatched {window.location.pathname.split("/")[2] + " " + window.location.pathname.split("/")[3]}s</h2>
    <button on:click={initUnmatched}>Initialize Unmatched List</button>
    <div class="unmatchedList">
        {#each links as link}
            <button on:click={() => {openTemplateBuilder(decodeURI(link.split("/")[4]))}}>{decodeURI(link.split("/")[4])}</button>
        {/each}
    </div>
</div>