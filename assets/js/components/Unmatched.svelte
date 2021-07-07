<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    let lang = window.location.pathname.split("/")[2];
    let wordClass = window.location.pathname.split("/")[3];
    let links = [];

    onMount(async () => {
        fetch(`/api/unmatched/${lang}/${wordClass}`).then((r) => {return r.json()}).then((d) => {
            var data = _.groupBy(d, function(datum) {return datum[1]});
            var arr = Object.values(data);
            arr = _.reverse(_.sortBy(arr, function(a) {return a.length}));
            arr = _.map(arr, function(a) {return a[0][0]});
            links = arr });
    })

    function openTemplateBuilder(link) {
        // debugger;
    
        links = _.filter(links, (l) => l != "https://en.wiktionary.org/wiki/" + encodeURI(link));
        window.open(`/testPage/${lang}/${link}/${wordClass}`);
    }

    function initUnmatched() {
        const regexp = /s$/ig;
        wordClass = wordClass.replaceAll(regexp, "");
        fetch(`/api/initUnmatched/${lang}/${wordClass}`, {method: "POST"});
    }

    function generateDefs() {
        const regexp = /s$/ig;
        wordClass = wordClass.replaceAll(regexp, "");
        fetch(`/api/buildWords/${lang}/${wordClass}`);
    }

</script>

<div>
    <h2 class="center">Unmatched {window.location.pathname.split("/")[2] + " " + window.location.pathname.split("/")[3]}s</h2>
    <button on:click={initUnmatched}>Initialize Unmatched List</button>
    <button on:click={generateDefs}>Generate Definitions</button>
    <div class="unmatchedList">
        {#each links as link}
            <button on:click={() => {openTemplateBuilder(decodeURI(link.split("/")[4]))}}>{decodeURI(link.split("/")[4].replaceAll("_", " "))}</button>
        {/each}
    </div>
</div>